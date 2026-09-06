#!/usr/bin/env bash
# verificar.sh — parte da skill seguranca-verificar (github.com/tiagomouraferraz/modelosdeskills)
#
# Só leitura. A única escrita possível é o arquivo de referência
# .claude/seguranca-verificar-baseline.txt, e só quando pedido por --baseline-criar
# ou --baseline-atualizar. Nunca imprime o valor de uma senha ou chave: toda saída
# de segredo é cortada em arquivo e linha.
#
# Uso (rodar de dentro da pasta do projeto, ou passar --pasta):
#   bash verificar.sh --inspecionar                 # descobre o que o projeto tem (Passo 0)
#   bash verificar.sh                               # verificação completa (Passo 1)
#   bash verificar.sh --acesso app.py               # inclui a checagem de integridade (1.7)
#   bash verificar.sh --acesso app.py --baseline-criar      # primeira vez
#   bash verificar.sh --acesso app.py --baseline-atualizar  # só depois de mudança confirmada
#   bash verificar.sh --pasta "C:/caminho/outra pasta"      # outra pasta do projeto
#   bash verificar.sh --instalar-protecao-commit            # so com autorizacao da pessoa (item 1.6)
#
# Saída: uma linha por item, no formato  ITEM|ESTADO|EVIDÊNCIA
# Estados: CORRETO, PROBLEMA, ERRO (comando falhou, não é "correto"), NAO_SE_APLICA, INFO

set -u
MODO=verificar; ACESSO=""; BASE_ACAO=""; PASTA="."
while [ $# -gt 0 ]; do
  case "$1" in
    --inspecionar) MODO=inspecionar ;;
    --instalar-protecao-commit) MODO=protecao ;;
    --acesso) ACESSO="${2:-}"; shift ;;
    --baseline-criar) BASE_ACAO=criar ;;
    --baseline-atualizar) BASE_ACAO=atualizar ;;
    --pasta) PASTA="${2:-.}"; shift ;;
    *) echo "ERRO|argumento desconhecido|$1"; exit 2 ;;
  esac
  shift
done

cd "$PASTA" 2>/dev/null || { echo "ERRO|pasta nao encontrada|$PASTA"; exit 2; }
TMP=$(mktemp -d 2>/dev/null || mktemp -d -t sv); trap 'rm -rf "$TMP"' EXIT
export GIT_TERMINAL_PROMPT=0

# Padrões de segredo (formatos conhecidos + atribuição genérica). Ajuste se souber de outro formato.
P='-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{60,}|AIza[0-9A-Za-z_-]{35}|GOCSPX-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9_-]{20,}|[sr]k_live_[A-Za-z0-9]{20,}|EAA[A-Za-z0-9]{40,}|xox[baprs]-[A-Za-z0-9-]{10,}|eyJ[A-Za-z0-9_-]{20,}\.eyJ[A-Za-z0-9_-]{20,}|(postgres|postgresql|mysql|mongodb(\+srv)?|redis)://[^:/[:space:]]+:[^@[:space:]]+@|(senha|password|passwd|secret|token|api_key|apikey)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{8,}'
# Placeholder: linha que contém um destes é exemplo, não segredo.
PH='exemplo|example|placeholder|troque|substitua|your_|seu_|sua_|xxx+|<[A-Za-z_ -]+>'
# Arquivos que nunca deveriam estar rastreados no git.
F='(^|/)(\.env(\..*)?|secrets\.toml|credentials\.json|client_secret.*\.json|service-account.*\.json|token\.json|token\.pickle|.*\.pem|.*\.key|.*\.p12)$'
# Linhas de segurança do arquivo de acesso (pra integridade).
R='st\.login|st\.user|st\.logout|login|logout|session|secret|password|senha|token|credential|admin|permiss'

out() { printf '%s|%s|%s\n' "$1" "$2" "$3"; }
hash_linhas() { # lê linhas na entrada, imprime um hash curto por linha (nunca o texto)
  if command -v sha256sum >/dev/null 2>&1; then H="sha256sum"; else H="shasum -a 256"; fi
  while IFS= read -r l; do printf '%s' "$l" | $H | cut -c1-16; done
}

if git rev-parse --show-toplevel >/dev/null 2>&1; then REPO=1; RAIZ=$(git rev-parse --show-toplevel); else REPO=0; RAIZ=$(pwd); fi

# ---------------------------------------------------------------- proteção mínima de commit (item 1.6)
# Escreve um hook pre-commit pequeno que bloqueia commit com padrão de segredo ou arquivo de
# credencial. Só roda quando a pessoa autorizou. Não sobrescreve hook de outra origem.
if [ "$MODO" = protecao ]; then
  [ "$REPO" = 1 ] || { out "protecao_de_commit" "NAO_SE_APLICA" "pasta sem git"; exit 0; }
  HK="$(git rev-parse --git-path hooks)/pre-commit"
  if [ -f "$HK" ] && ! grep -q 'seguranca-verificar' "$HK"; then
    out "protecao_de_commit" "INFO" "ja existe um hook pre-commit de outra origem em $HK; nao foi alterado. Conferir se ele varre segredo"
    exit 0
  fi
  mkdir -p "$(dirname "$HK")"
  {
    echo '#!/bin/sh'
    echo '# Protecao minima de commit instalada pela skill seguranca-verificar (modelosdeskills).'
    echo '# Bloqueia commit que adicione padrao de senha/chave ou arquivo de credencial. Remover este arquivo desliga a protecao.'
    # os padroes tem aspas simples dentro; escapar pra caber entre aspas simples no hook
    printf "P='%s'\n" "$(printf '%s' "$P" | sed "s/'/'\\\\''/g")"
    printf "PH='%s'\n" "$(printf '%s' "$PH" | sed "s/'/'\\\\''/g")"
    printf "F='%s'\n" "$(printf '%s' "$F" | sed "s/'/'\\\\''/g")"
    echo 'if git diff --cached -U0 | grep -E "^\+[^+]" | grep -EI -e "$P" | grep -qviE "$PH"; then'
    echo '  echo "BLOQUEADO pela protecao de commit: ha padrao de senha ou chave no que vai ser salvo. Tire o segredo do arquivo (lugar certo: .env ou o painel de secrets da plataforma) e tente de novo."; exit 1; fi'
    echo 'if git diff --cached --name-only | grep -iE "$F" | grep -qviE "exemplo|example|sample"; then'
    echo '  echo "BLOQUEADO pela protecao de commit: arquivo de credencial (.env, secrets, chave) nao pode ir pro git. Adicione ao .gitignore."; exit 1; fi'
    echo 'exit 0'
  } > "$HK"
  chmod +x "$HK" 2>/dev/null
  out "protecao_de_commit" "CORRETO" "hook pre-commit instalado em $HK (bloqueia segredo e arquivo de credencial em todo commit, inclusive feito fora do Claude Code)"
  exit 0
fi

# ---------------------------------------------------------------- inspeção (Passo 0)
if [ "$MODO" = inspecionar ]; then
  out "pasta" "INFO" "$RAIZ"
  if [ "$REPO" = 1 ]; then
    rem=$(git remote get-url origin 2>/dev/null | sed -E 's#//[^/@]+@#//<credencial-oculta>@#')
    out "repositorio_git" "INFO" "sim; remoto: ${rem:-nenhum}"
  else
    out "repositorio_git" "INFO" "nao (pasta sem git)"
  fi
  cred=$(ls -a 2>/dev/null | grep -iE '^\.env|secret|credential|token\.(json|pickle)' | tr '\n' ' ')
  [ -f .streamlit/secrets.toml ] && cred="$cred .streamlit/secrets.toml"
  out "arquivos_de_credencial_na_pasta" "INFO" "${cred:-nenhum encontrado}"
  dep=$(ls requirements.txt package.json pyproject.toml 2>/dev/null | tr '\n' ' ')
  out "arquivo_de_dependencias" "INFO" "${dep:-nenhum}"
  pub=$(ls vercel.json netlify.toml Procfile Dockerfile app.yaml streamlit_app.py 2>/dev/null | tr '\n' ' ')
  [ -d .streamlit ] && pub="$pub .streamlit/"
  out "sinais_de_app_publicado" "INFO" "${pub:-nenhum}"
  if [ "$REPO" = 1 ]; then
    cand=$(git grep -ilE 'st\.login|st\.user|login|auth|session|admin|permiss' 2>/dev/null | head -5 | tr '\n' ' ')
  else
    cand=$(grep -rilE --exclude-dir=.git --exclude-dir=node_modules 'st\.login|st\.user|login|auth|session|admin|permiss' . 2>/dev/null | head -5 | tr '\n' ' ')
  fi
  out "candidatos_a_arquivo_de_acesso" "INFO" "${cand:-nenhum}"
  # serviços que o código usa (pra deduzir as contas que sustentam o projeto)
  serv=""
  if [ "$REPO" = 1 ]; then busca() { git grep -qiE "$1" 2>/dev/null; }; else busca() { grep -rqiE --exclude-dir=.git --exclude-dir=node_modules "$1" . 2>/dev/null; }; fi
  busca 'import streamlit|st\.secrets' && serv="$serv Streamlit-Cloud"
  busca 'gspread|googleapis|google\.oauth2|sheets\.googleapis|drive\.googleapis' && serv="$serv Google(planilhas/Drive/API)"
  busca 'facebook_business|graph\.facebook\.com|facebook\.com/v[0-9]' && serv="$serv Meta(Business-Manager)"
  busca 'googleads|google-ads|GoogleAdsClient' && serv="$serv Google-Ads"
  busca 'supabase' && serv="$serv Supabase"
  busca 'openai|anthropic' && serv="$serv API-de-IA(OpenAI/Anthropic)"
  [ -f vercel.json ] && serv="$serv Vercel"
  [ -f netlify.toml ] && serv="$serv Netlify"
  git remote get-url origin 2>/dev/null | grep -q github.com && serv="$serv GitHub"
  out "servicos_detectados_no_codigo" "INFO" "${serv:-nenhum reconhecido}"
  exit 0
fi

# ---------------------------------------------------------------- verificação (Passo 1)
cd "$RAIZ" || exit 2

# 1.1 segredo no estado atual
if [ "$REPO" = 1 ]; then
  git ls-files -z | xargs -0 grep -nHEI -e "$P" > "$TMP/11" 2> "$TMP/11e"
else
  grep -rnHEI --exclude-dir=.git --exclude-dir=node_modules -e "$P" . > "$TMP/11" 2> "$TMP/11e"
fi
grep -viE "$PH" "$TMP/11" | cut -d: -f1,2 > "$TMP/11f"
LIMPO11=0
if [ -s "$TMP/11e" ] && ! [ -s "$TMP/11" ]; then
  out "1.1 segredo no estado atual" "ERRO" "grep falhou: $(head -1 "$TMP/11e")"
elif [ -s "$TMP/11f" ]; then
  out "1.1 segredo no estado atual" "PROBLEMA" "padrao de segredo em: $(tr '\n' ' ' < "$TMP/11f")(arquivo:linha; trocar a credencial antes de qualquer outra coisa)"
else
  LIMPO11=1; out "1.1 segredo no estado atual" "CORRETO" "nenhum padrao de segredo nos arquivos rastreados"
fi

if [ "$REPO" = 1 ]; then
  # 1.2 segredo no histórico
  git log --all -p > "$TMP/hist" 2>/dev/null
  n=$(grep -EI -e "$P" "$TMP/hist" | grep -vciE "$PH")
  if [ "${n:-0}" -gt 0 ]; then
    cm=$(git log --all --format='%h %ad' --date=short -E -G"$P" 2>/dev/null | head -5 | tr '\n' ';')
    out "1.2 segredo no historico do git" "PROBLEMA" "$n linha(s) com padrao de segredo no historico; commits: ${cm:-?}. Trocar a credencial primeiro; limpar historico e decisao separada, fora desta skill"
  else
    out "1.2 segredo no historico do git" "CORRETO" "nenhum padrao de segredo no historico"
  fi

  # 1.3 arquivo de credencial rastreado
  t=$(git ls-files | grep -iE "$F" | grep -viE 'exemplo|example|sample' | tr '\n' ' ')
  if [ -n "$t" ]; then out "1.3 arquivo de credencial rastreado" "PROBLEMA" "rastreado no git: $t"; else out "1.3 arquivo de credencial rastreado" "CORRETO" "nenhum"; fi

  # 1.4 .gitignore cobre credencial
  d=""; for f in .env .streamlit/secrets.toml credentials.json client_secret.json token.json service-account.json; do git check-ignore -q "$f" || d="$d $f"; done
  if [ -n "$d" ]; then out "1.4 .gitignore cobre credencial" "PROBLEMA" "descoberto:$d (correcao segura: adicionar essas linhas ao .gitignore, com sua confirmacao)"; else out "1.4 .gitignore cobre credencial" "CORRETO" "todos cobertos"; fi
else
  out "1.2 segredo no historico do git" "NAO_SE_APLICA" "pasta sem git"
  out "1.3 arquivo de credencial rastreado" "NAO_SE_APLICA" "pasta sem git"
  out "1.4 .gitignore cobre credencial" "NAO_SE_APLICA" "pasta sem git"
fi

# 1.5 dependência com versão fixada (informativo)
if [ -f requirements.txt ]; then
  u=$(grep -vE '^[[:space:]]*(#|$|-|git\+)' requirements.txt | grep -v '==' | tr '\n' ' ')
  if [ -n "$u" ]; then out "1.5 dependencia com versao fixada" "INFO" "sem versao exata (==): $u. Evita que uma atualizacao automatica troque o comportamento do app sem voce saber"; else out "1.5 dependencia com versao fixada" "CORRETO" "requirements.txt com versao exata"; fi
elif [ -f package.json ]; then
  if ls package-lock.json yarn.lock pnpm-lock.yaml >/dev/null 2>&1; then out "1.5 dependencia com versao fixada" "CORRETO" "lockfile presente"; else out "1.5 dependencia com versao fixada" "INFO" "package.json sem lockfile"; fi
else
  out "1.5 dependencia com versao fixada" "NAO_SE_APLICA" "sem arquivo de dependencias"
fi

# 1.6 proteção de commit
if [ "$REPO" = 1 ]; then
  hk="$(git rev-parse --git-path hooks)/pre-commit"
  if [ -f "$hk" ]; then
    if grep -qiE 'segredo|secret|gitleaks|detect-secrets' "$hk"; then out "1.6 protecao de commit" "CORRETO" "hook pre-commit presente e parece varrer segredo"; else out "1.6 protecao de commit" "INFO" "hook pre-commit existe, mas nao parece varrer segredo (conteudo nao verificado)"; fi
  else
    out "1.6 protecao de commit" "PROBLEMA" "sem hook pre-commit: nada impede commit de segredo. Instalar a skill seguranca-instalarbarreiras deste repositorio ou um verificador de segredo (ex: gitleaks)"
  fi
else
  out "1.6 protecao de commit" "NAO_SE_APLICA" "pasta sem git"
fi

# 1.7 integridade do arquivo de acesso
if [ -n "$ACESSO" ]; then
  BL=".claude/seguranca-verificar-baseline.txt"
  if [ ! -f "$ACESSO" ]; then
    out "1.7 integridade do arquivo de acesso" "ERRO" "arquivo nao encontrado: $ACESSO (caminho relativo a $RAIZ)"
  else
    FONTE="copia LOCAL (sem remoto ou sem acesso a ele)"; B=""
    if [ "$REPO" = 1 ]; then
      B=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
      if [ -z "$B" ]; then for c in origin/main origin/master; do git rev-parse -q --verify "$c" >/dev/null 2>&1 && { B=$c; break; }; done; fi
      if [ -n "$B" ]; then
        git fetch -q origin 2>/dev/null
        rel=$(git ls-files --full-name "$ACESSO" 2>/dev/null | head -1)
        if [ -n "$rel" ] && git show "$B:$rel" > "$TMP/at" 2>/dev/null; then FONTE="versao publicada ($B)"; fi
      fi
    fi
    [ -f "$TMP/at" ] || cp "$ACESSO" "$TMP/at"
    grep -EI -e "$R" "$TMP/at" > "$TMP/lin"
    hash_linhas < "$TMP/lin" > "$TMP/h"
    nl=$(wc -l < "$TMP/lin" | tr -d ' ')
    if [ "$BASE_ACAO" = atualizar ] || { [ ! -f "$BL" ] && [ "$BASE_ACAO" = criar ]; }; then
      if [ "$LIMPO11" = 1 ]; then
        mkdir -p .claude
        { echo "# seguranca-verificar: hashes das $nl linhas de seguranca de $ACESSO ($FONTE). Sem texto de codigo."; cat "$TMP/h"; } > "$BL"
        out "1.7 integridade do arquivo de acesso" "INFO" "referencia $( [ "$BASE_ACAO" = criar ] && echo criada || echo atualizada ) com $nl linha(s) de seguranca, fonte: $FONTE. Sem comparacao nesta rodada"
      else
        out "1.7 integridade do arquivo de acesso" "PROBLEMA" "referencia NAO gravada: o item 1.1 encontrou segredo; resolver primeiro"
      fi
    elif [ ! -f "$BL" ]; then
      out "1.7 integridade do arquivo de acesso" "INFO" "sem referencia ainda; rodar com --baseline-criar depois de confirmar com a pessoa que o arquivo esta como deveria"
    else
      grep -v '^#' "$BL" > "$TMP/hb"
      if diff -q "$TMP/h" "$TMP/hb" >/dev/null; then
        out "1.7 integridade do arquivo de acesso" "CORRETO" "$nl linha(s) de seguranca iguais a referencia; fonte: $FONTE"
      else
        novas=$(grep -vxFf "$TMP/hb" "$TMP/h" | wc -l | tr -d ' '); rem=$(grep -vxFf "$TMP/h" "$TMP/hb" | wc -l | tr -d ' ')
        det=""
        if [ "$LIMPO11" = 1 ] && [ "$novas" -gt 0 ]; then
          paste -d'|' "$TMP/h" "$TMP/lin" | grep -vFf "$TMP/hb" | cut -d'|' -f2- | head -5 > "$TMP/nov"
          det="; linhas novas: $(tr '\n' ' ' < "$TMP/nov")"
        fi
        out "1.7 integridade do arquivo de acesso" "PROBLEMA" "ALERTA: linhas de seguranca mudaram ($novas nova(s), $rem removida(s)); fonte: $FONTE$det. Se a pessoa nao reconhece a mudanca, investigar git log -p -- $ACESSO antes de qualquer outra coisa"
      fi
    fi
  fi
else
  out "1.7 integridade do arquivo de acesso" "NAO_SE_APLICA" "sem arquivo de acesso configurado"
fi

# 1.8 arquivo de dado rastreado (revisar)
if [ "$REPO" = 1 ]; then
  dd=$(git ls-files | grep -iE '\.(csv|xlsx|xls|pdf)$' | head -20 | tr '\n' ' ')
  if [ -n "$dd" ]; then out "1.8 arquivo de dado rastreado" "INFO" "revisar se contem dado de cliente: $dd"; else out "1.8 arquivo de dado rastreado" "CORRETO" "nenhum csv/xlsx/pdf rastreado"; fi
fi

# 1.9 variável pública de frontend com nome sensível
if [ "$REPO" = 1 ]; then
  fv=$(git grep -nE '(NEXT_PUBLIC|VITE|REACT_APP)_[A-Z_]*(SECRET|SERVICE|PRIVATE|TOKEN)' 2>/dev/null | cut -d: -f1,2 | head -5 | tr '\n' ' ')
  if [ -n "$fv" ]; then out "1.9 variavel publica de frontend com nome sensivel" "PROBLEMA" "vai pro navegador de qualquer visitante: $fv"; else out "1.9 variavel publica de frontend com nome sensivel" "CORRETO" "nenhuma"; fi
fi

out "FIM" "INFO" "verificacao concluida em $RAIZ"
