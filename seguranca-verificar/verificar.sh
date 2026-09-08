#!/usr/bin/env bash
# verificar.sh — parte da skill seguranca-verificar (github.com/tiagomouraferraz/modelosdeskills)
#
# Só leitura. A única escrita possível é o arquivo de referência
# .seguranca-verificar/baseline.txt, e só quando pedido por --baseline-criar
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
VERSAO="0.3.3"
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
# Borda à esquerda em sk- e EAA: sem ela, "EAA" cai por acaso dentro de qualquer base64 grande
# (fonte, imagem embutida) e "sk-" cai dentro de nome de classe CSS ("mask-image-..."). O "^[-+]?"
# deixa passar o sinal de linha de diff, pra varredura de histórico continuar pegando token sozinho na linha.
P='-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{60,}|AIza[0-9A-Za-z_-]{35}|GOCSPX-[A-Za-z0-9_-]{20,}|(^[-+]?|[^A-Za-z0-9])sk-(proj-)?[A-Za-z0-9]{20,}|[sr]k_live_[A-Za-z0-9]{20,}|sb_(secret|publishable)_[A-Za-z0-9_-]{20,}|(^[-+]?|[^A-Za-z0-9+/])EAA[A-Za-z0-9]{40,}|xox[baprs]-[A-Za-z0-9-]{10,}|eyJ[A-Za-z0-9_-]{20,}\.eyJ[A-Za-z0-9_-]{20,}|(postgres|postgresql|mysql|mongodb(\+srv)?|redis)://[^:/[:space:]]+:[^@[:space:]]+@|(senha|password|passwd|secret|token|api_key|apikey)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{8,}'
# Placeholder: linha que contém um destes é exemplo, não segredo. Aceita hífen e sublinhado
# ("seu-token-aqui" e "seu_token_aqui"), porque instrução escrita em português usa os dois.
PH='exemplo|example|placeholder|troque|substitua|your[-_]|seu[-_]|sua[-_]|xxx+|<[A-Za-z_ -]+>'
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

# Repositório em SUBPASTA. Sem isto, uma raiz sem git faz 1.2, 1.3, 1.4 e 1.6 saírem como
# "não se aplica" — que se lê como "não há o que verificar aqui", quando pode ser o oposto:
# repositório com remoto, histórico e .gitignore, tudo por verificar, uma pasta abaixo.
SUB=$(find . -mindepth 2 -maxdepth 4 -type d -name .git 2>/dev/null | sed 's#/\.git$##; s#^\./##' | grep -v node_modules | head -5 | tr '\n' ' ')

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
    printf '# versao dos padroes: %s\n' "$VERSAO"
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
  out "protecao_de_commit" "CORRETO" "hook pre-commit instalado em $HK (bloqueia segredo e arquivo de credencial em todo commit, inclusive feito fora do assistente)"
  exit 0
fi

# ---------------------------------------------------------------- inspeção (Passo 0)
if [ "$MODO" = inspecionar ]; then
  out "pasta" "INFO" "$(pwd)"
  if [ "$REPO" = 1 ]; then
    rem=$(git remote get-url origin 2>/dev/null | sed -E 's#//[^/@]+@#//<credencial-oculta>@#')
    if [ "$(cd "$RAIZ" && pwd)" != "$(pwd)" ]; then out "repositorio_git" "INFO" "sim, mas esta pasta e subpasta de um repositorio maior ($RAIZ); remoto: ${rem:-nenhum}"; else out "repositorio_git" "INFO" "sim; remoto: ${rem:-nenhum}"; fi
  else
    out "repositorio_git" "INFO" "nao (pasta sem git)"
  fi
  out "repositorio_git_em_subpasta" "INFO" "${SUB:-nenhum ate 3 niveis abaixo}"
  cred=$(ls -a 2>/dev/null | grep -iE '^\.env|secret|credential|token\.(json|pickle)' | tr '\n' ' ')
  [ -f .streamlit/secrets.toml ] && cred="$cred .streamlit/secrets.toml"
  out "arquivos_de_credencial_na_pasta" "INFO" "${cred:-nenhum encontrado}"
  dep=$(ls requirements.txt package.json pyproject.toml 2>/dev/null | tr '\n' ' ')
  out "arquivo_de_dependencias" "INFO" "${dep:-nenhum}"
  pub=$(ls vercel.json netlify.toml Procfile Dockerfile app.yaml streamlit_app.py 2>/dev/null | tr '\n' ' ')
  [ -d .streamlit ] && pub="$pub .streamlit/"
  # .vercel/ e .netlify/ = publicacao feita direto desta pasta por linha de comando (sem precisar de git)
  [ -d .vercel ] && pub="$pub .vercel/(publica-desta-pasta)"
  [ -d .netlify ] && pub="$pub .netlify/(publica-desta-pasta)"
  out "sinais_de_app_publicado" "INFO" "${pub:-nenhum}"
  if [ "$REPO" = 1 ]; then
    cand=$(git grep -ilE 'st\.login|st\.user|login|auth|session|admin|permiss' -- . 2>/dev/null | head -5 | tr '\n' ' ')
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
  # pasta dentro de sincronização de nuvem: tudo aqui já vai pra nuvem, inclusive .env e cópias
  case "$(pwd)" in
    *OneDrive*|*"Google Drive"*|*GoogleDrive*|*Dropbox*|*iCloud*) out "pasta_sincronizada_na_nuvem" "INFO" "sim (o caminho passa por um servico de sincronizacao)";;
    *) out "pasta_sincronizada_na_nuvem" "INFO" "nao pelo caminho";;
  esac
  exit 0
fi

# ---------------------------------------------------------------- verificação (Passo 1)
# A verificação roda na pasta em que foi chamada. Se ela for uma subpasta de um repositório
# maior, os comandos do git ficam restritos a ela (pathspec "-- ."), e isso é avisado.
AQUI=$(pwd)
if [ "$REPO" = 1 ] && [ "$(cd "$RAIZ" && pwd)" != "$AQUI" ]; then
  out "pasta" "INFO" "esta pasta faz parte de um repositorio maior ($RAIZ); verificando so o que esta dentro dela"
fi

# 1.1 segredo no estado atual
if [ "$REPO" = 1 ]; then
  git ls-files -z -- . | xargs -0 grep -nHEI -e "$P" > "$TMP/11" 2> "$TMP/11e"
else
  # sem git: todos os arquivos da pasta, menos os de credencial (.env e afins), que sao o lugar certo de um segredo
  grep -rnHEI --exclude-dir=.git --exclude-dir=node_modules -e "$P" . 2> "$TMP/11e" | grep -vE "^[^:]*/?($(printf '%s' "$F" | sed 's/^(^|\/)//; s/\$$//'))" > "$TMP/11"
fi
# O filtro de placeholder olha só o conteúdo da linha, nunca o "arquivo:linha" na frente dela:
# um arquivo chamado "exemplo.env" ou "seu-projeto.py" com chave de verdade tem que aparecer.
so_conteudo() { while IFS= read -r l; do printf '%s' "${l#*:*:}" | grep -qiE "$PH" || printf '%s\n' "$l"; done; }
so_conteudo < "$TMP/11" | cut -d: -f1,2 > "$TMP/11f"
# com git: arquivo da pasta que nao esta no git (e nao esta ignorado) tambem vai junto em copia ou nuvem; linha propria
NAO_RASTREADO=""
if [ "$REPO" = 1 ]; then
  git ls-files -z --others --exclude-standard -- . | xargs -0 grep -nHEI -e "$P" 2>/dev/null | grep -vE "^[^:]*/?($(printf '%s' "$F" | sed 's/^(^|\/)//; s/\$$//'))" | so_conteudo | cut -d: -f1,2 > "$TMP/11n"
  [ -s "$TMP/11n" ] && NAO_RASTREADO=$(tr '\n' ' ' < "$TMP/11n")
fi
LIMPO11=0
if [ -s "$TMP/11e" ] && ! [ -s "$TMP/11" ]; then
  out "1.1 segredo no estado atual" "ERRO" "grep falhou: $(head -1 "$TMP/11e")"
elif [ -s "$TMP/11f" ]; then
  out "1.1 segredo no estado atual" "PROBLEMA" "padrao de segredo em: $(tr '\n' ' ' < "$TMP/11f")(arquivo:linha; trocar a credencial antes de qualquer outra coisa)"
else
  if [ "$REPO" = 1 ]; then ONDE11="nos arquivos rastreados"; else ONDE11="nos arquivos da pasta (fora os de credencial)"; fi
  LIMPO11=1; out "1.1 segredo no estado atual" "CORRETO" "nenhum padrao de segredo $ONDE11"
fi
[ -n "$NAO_RASTREADO" ] && out "1.1 segredo em arquivo fora do git" "PROBLEMA" "padrao de segredo em: $NAO_RASTREADO(arquivo:linha; nao esta no git, mas esta na pasta e vai junto em copia ou nuvem; trocar a credencial e tirar do arquivo)"

if [ "$REPO" = 1 ]; then
  # 1.2 segredo no histórico
  git log --all -p -- . > "$TMP/hist" 2>/dev/null
  n=$(grep -EI -e "$P" "$TMP/hist" | grep -vciE "$PH")
  if [ "${n:-0}" -gt 0 ]; then
    cm=$(git log --all --format='%h %ad' --date=short -E -G"$P" -- . 2>/dev/null | head -5 | tr '\n' ';')
    out "1.2 segredo no historico do git" "PROBLEMA" "$n linha(s) com padrao de segredo no historico; commits: ${cm:-?}. Trocar a credencial primeiro; limpar historico e decisao separada, fora desta skill"
  else
    out "1.2 segredo no historico do git" "CORRETO" "nenhum padrao de segredo no historico"
  fi

  # 1.3 arquivo de credencial rastreado
  t=$(git ls-files -- . | grep -iE "$F" | grep -viE 'exemplo|example|sample' | tr '\n' ' ')
  if [ -n "$t" ]; then out "1.3 arquivo de credencial rastreado" "PROBLEMA" "rastreado no git: $t"; else out "1.3 arquivo de credencial rastreado" "CORRETO" "nenhum"; fi

  # 1.4 .gitignore cobre credencial
  d=""; for f in .env .streamlit/secrets.toml credentials.json client_secret.json token.json service-account.json; do git check-ignore -q "$f" || d="$d $f"; done
  if [ -n "$d" ]; then out "1.4 .gitignore cobre credencial" "PROBLEMA" "descoberto:$d (correcao segura: adicionar essas linhas ao .gitignore, com sua confirmacao)"; else out "1.4 .gitignore cobre credencial" "CORRETO" "todos cobertos"; fi
else
  if [ -n "$SUB" ]; then AVISO="esta pasta nao tem git, mas ha repositorio em: $SUB(rodar de novo com --pasta pra verificar la dentro)"; else AVISO="pasta sem git"; fi
  out "1.2 segredo no historico do git" "NAO_SE_APLICA" "$AVISO"
  out "1.3 arquivo de credencial rastreado" "NAO_SE_APLICA" "$AVISO"
  out "1.4 .gitignore cobre credencial" "NAO_SE_APLICA" "$AVISO"
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
    if grep -q 'seguranca-verificar' "$hk"; then
      hv=$(sed -n 's/^# versao dos padroes: //p' "$hk" | head -1)
      if [ "$hv" = "$VERSAO" ]; then
        out "1.6 protecao de commit" "CORRETO" "hook pre-commit desta skill instalado, com os padroes da versao atual ($VERSAO)"
      else
        out "1.6 protecao de commit" "PROBLEMA" "hook pre-commit desta skill instalado com padroes antigos (${hv:-sem versao}; atual: $VERSAO). Os padroes ficam gravados dentro do hook e nao se atualizam sozinhos: correcao de padrao que gera alarme falso so vale depois de reinstalar com --instalar-protecao-commit"
      fi
    elif grep -qiE 'segredo|secret|gitleaks|detect-secrets' "$hk"; then
      out "1.6 protecao de commit" "CORRETO" "hook pre-commit presente e parece varrer segredo"
    else
      out "1.6 protecao de commit" "INFO" "hook pre-commit existe, mas nao parece varrer segredo (conteudo nao verificado)"
    fi
  else
    out "1.6 protecao de commit" "PROBLEMA" "sem hook pre-commit: nada impede commit de segredo. Este script instala uma protecao minima com --instalar-protecao-commit (so com autorizacao da pessoa)"
  fi
else
  if [ -n "$SUB" ]; then out "1.6 protecao de commit" "NAO_SE_APLICA" "esta pasta nao tem git, mas ha repositorio em: $SUB(rodar de novo com --pasta pra verificar la dentro)"; else out "1.6 protecao de commit" "NAO_SE_APLICA" "pasta sem git"; fi
fi

# 1.7 integridade do arquivo de acesso
if [ -n "$ACESSO" ]; then
  BL=".seguranca-verificar/baseline.txt"
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
        mkdir -p .seguranca-verificar
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

# 1.8 arquivo de dado (revisar): rastreado no git ou, sem git, presente na pasta
if [ "$REPO" = 1 ]; then
  dd=$(git ls-files -- . | grep -iE '\.(csv|xlsx|xls|pdf)$' | head -20 | tr '\n' ' ')
  if [ -n "$dd" ]; then out "1.8 arquivo de dado rastreado" "INFO" "revisar se contem dado de cliente: $dd"; else out "1.8 arquivo de dado rastreado" "CORRETO" "nenhum csv/xlsx/pdf rastreado"; fi
else
  dd=$(find . -path ./node_modules -prune -o -type f \( -iname '*.csv' -o -iname '*.xlsx' -o -iname '*.xls' -o -iname '*.pdf' \) -print 2>/dev/null | head -20 | tr '\n' ' ')
  if [ -n "$dd" ]; then out "1.8 arquivo de dado na pasta" "INFO" "sem git aqui, mas revisar se contem dado de cliente e se a pasta e sincronizada ou publicada: $dd"; else out "1.8 arquivo de dado na pasta" "CORRETO" "nenhum csv/xlsx/pdf na pasta"; fi
fi

# 1.9 variável pública de frontend com nome sensível
FV='(NEXT_PUBLIC|VITE|REACT_APP)_[A-Z_]*(SECRET|SERVICE|PRIVATE|TOKEN)'
if [ "$REPO" = 1 ]; then
  fv=$(git grep -nE "$FV" -- . 2>/dev/null | cut -d: -f1,2 | head -5 | tr '\n' ' ')
else
  fv=$(grep -rnE --exclude-dir=.git --exclude-dir=node_modules "$FV" . 2>/dev/null | cut -d: -f1,2 | head -5 | tr '\n' ' ')
fi
if [ -n "$fv" ]; then out "1.9 variavel publica de frontend com nome sensivel" "PROBLEMA" "vai pro navegador de qualquer visitante: $fv"; else out "1.9 variavel publica de frontend com nome sensivel" "CORRETO" "nenhuma"; fi

# 1.11 cópia de backup de arquivo de credencial
# Backup de credencial é o arquivo que sobrevive a uma troca de chave: a pessoa rotaciona, acha
# que resolveu, e a chave antiga continua válida dentro do .bak esquecido. Nenhum outro item
# enxerga isso: o 1.1 pula arquivo de credencial (é o lugar certo do segredo) e o 1.3 só olha o
# que está rastreado no git — e backup normalmente não está.
BK=$(find . -maxdepth 5 -type f 2>/dev/null | grep -iE '(\.env|secrets\.toml|credentials\.json|client_secret[^/]*\.json|service-account[^/]*\.json|token\.json|\.pem|\.key)[^/]*(\.bak|\.old|\.orig|\.copy|~|[-_.](backup|copia|antigo)|[-_.][0-9]{6,})' | grep -v node_modules | head -10 | tr '\n' ' ')
if [ -n "$BK" ]; then
  out "1.11 backup de arquivo de credencial" "PROBLEMA" "copia de credencial parada na pasta: $BK(a chave que esta dentro dela pode continuar valendo mesmo depois de voce trocar a atual; conferir se a antiga ja foi revogada no painel do servico e so entao apagar o arquivo)"
else
  out "1.11 backup de arquivo de credencial" "CORRETO" "nenhuma copia de backup de credencial na pasta"
fi

# 1.12 permissão do arquivo de credencial (só Unix; no Windows não há equivalente direto)
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) out "1.12 permissao do arquivo de credencial" "NAO_SE_APLICA" "Windows nao tem equivalente direto da permissao de arquivo do Unix; o controle aqui e quem tem conta na maquina" ;;
  *)
    ab=""
    for f in $(find . -maxdepth 5 -type f 2>/dev/null | grep -iE "$F" | grep -v node_modules | head -10); do
      p=$(stat -c %a "$f" 2>/dev/null || stat -f %A "$f" 2>/dev/null)
      case "$p" in 600|400|700|"") ;; *) ab="$ab $f($p)" ;; esac
    done
    if [ -n "$ab" ]; then
      out "1.12 permissao do arquivo de credencial" "PROBLEMA" "legivel por outro usuario da maquina:$ab (correcao: chmod 600 em cada um, com sua confirmacao)"
    else
      out "1.12 permissao do arquivo de credencial" "CORRETO" "nenhum arquivo de credencial legivel por outro usuario da maquina"
    fi ;;
esac

out "FIM" "INFO" "verificacao concluida em $AQUI"
