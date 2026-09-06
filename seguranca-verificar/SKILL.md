---
name: seguranca-verificar
description: >
  Roda uma verificação de segurança real e verificável num projeto de Claude Code: senha ou chave
  escrita em código ou guardada no histórico do git, arquivo de credencial fora do .gitignore,
  dependência sem versão fixada, proteção de commit instalada, arquivo de dado de cliente
  rastreado, e integridade do arquivo que controla login e acesso contra uma referência guardada
  só em hash. Cada item termina em um de três estados (verificado e correto, verificado com
  problema, fora do alcance do agente), nunca em "está tudo OK" genérico. Na primeira execução
  faz uma configuração guiada em linguagem simples, com opção de o agente inspecionar o projeto
  sozinho mediante autorização. Use quando o usuário chamar /seguranca-verificar, disser "confere
  a segurança do projeto", "roda a checagem de segurança", "faz uma auditoria de segurança", ou
  depois de qualquer mudança real: código publicado alterado, senha ou chave nova, integração
  nova, dependência nova.
---

# /seguranca-verificar

Feita pra projeto de quem não programa e usa o Claude Code na operação. O agente executa e explica;
a pessoa autoriza e responde só o que só ela sabe. Todo texto entre aspas nos passos abaixo é o
texto a mostrar pra pessoa, do jeito que está. Os comandos moram em `verificar.sh`, na mesma pasta
deste arquivo: o agente roda o script e interpreta a saída, não digita comando solto.

## Regra permanente: três estados, nunca "está tudo OK"

Cada item termina obrigatoriamente em um destes estados:

- **Verificado e correto**: com a evidência que o script imprimiu.
- **Verificado e com problema**: trazido pra pessoa com a correção proposta. A única correção que
  o agente aplica sozinho, e só depois de confirmação na tela, é acrescentar linha ao `.gitignore`
  (item 1.4). Qualquer outra (trocar credencial, apagar arquivo, reescrever histórico) é decisão e
  ação da pessoa.
- **Fora do alcance do agente**: não existe ferramenta aqui pra checar (painel de site, conta
  online, celular). Vira pergunta pra pessoa, nunca suposição silenciosa de que está bem.

Saída `ERRO` do script nunca vira "correto": é "não foi possível verificar", com o motivo.

## Segurança do próprio processo (ler antes de rodar qualquer coisa)

- **Só leitura, com duas exceções nomeadas:** o arquivo de configuração e o de referência da própria
  skill, os dois dentro de `.claude/` do projeto, e a linha no `.gitignore` do item 1.4 com
  confirmação. Nada mais é alterado.
- **Nenhum valor de senha ou chave aparece no chat, na configuração ou na referência.** O script
  corta a saída em arquivo e linha, mascara credencial embutida em endereço de repositório, e a
  referência de integridade guarda só hash das linhas, nunca o texto.
- **Antes da inspeção automática, dizer em uma frase o que vai ser feito e pedir autorização.**
- O script não instala nada, não executa código do projeto e só acessa a internet pra
  `git fetch` do próprio repositório do projeto, sem pedir senha (se precisar, ele desiste e usa a
  cópia local, e diz isso).
- **Esta skill não reescreve histórico do git e não faz push.** Se aparecer segredo no histórico,
  o caminho é: a pessoa troca a credencial no serviço de origem primeiro; a limpeza do histórico é
  decisão separada dela, fora desta skill.

## Passo 0: primeira execução (configuração guiada)

Se `.claude/seguranca-verificar.md` não existir na raiz do projeto, fazer esta configuração. Se
existir, ir direto pro Passo 1.

1. Confirmar a pasta: rodar `bash <pasta-da-skill>/verificar.sh --inspecionar` só depois de mostrar
   o caminho atual e perguntar "É esta a pasta do projeto que você quer verificar?". Pasta errada
   é o único jeito de esta skill produzir resultado enganoso.
2. Explicar: "Esta skill confere a segurança do seu projeto e precisa saber cinco coisas sobre ele.
   Nada de senha ou chave: só onde as coisas ficam. Você escolhe como responder:"
   - "(A) Deixa eu olhar a pasta do projeto e preencher sozinho. Eu só leio arquivos, não mudo
     nada, não mostro nenhuma senha e no fim você confirma ou corrige cada resposta."
   - "(B) Prefiro responder às perguntas eu mesmo."
3. **Opção A, depois da autorização explícita:** rodar `verificar.sh --inspecionar`. Ele imprime
   se a pasta é repositório git e o endereço remoto (com credencial mascarada), arquivos de
   credencial presentes, arquivo de dependências, sinais de app publicado e candidatos a arquivo de
   acesso. Transformar isso em resposta proposta pra P1, P2 e P3; mostrar cada pergunta com a
   proposta e pedir confirmação ou correção. P4 e P5 são sempre perguntadas.
4. **Opção B, ou pra completar a A:** perguntar, uma de cada vez, com o texto e os exemplos como
   estão.

   - **P1** "Alguma parte deste projeto fica no ar, na internet, pra outra pessoa acessar? Exemplos
     comuns: um painel de resultados que o cliente abre por link, um site, um formulário de
     cadastro, um dashboard. Se sim, em qual serviço ele está hospedado? Exemplos: Streamlit Cloud,
     Vercel, WordPress, Hostinger, Google Sites. Se não tiver nada no ar, responde 'não'."
   - **P2** "Onde ficam as senhas e chaves que o projeto usa? 'Chave' aqui é qualquer código que dá
     acesso a alguma coisa: token do Meta Ads, chave de API do Google, senha de banco de dados,
     senha de e-mail. As respostas mais comuns: (1) num arquivo chamado `.env` dentro da pasta do
     projeto; (2) no painel de 'Secrets' ou 'Variáveis de ambiente' do serviço onde o app está
     hospedado; (3) escrita direto dentro do código do app; (4) não sei. As respostas 3 e 4 são
     válidas e já viram o primeiro item a resolver."
   - **P3** "Existe um arquivo do projeto que controla quem pode entrar e o que cada pessoa vê?
     Exemplo comum: o arquivo principal de um painel de cliente, que faz o login e mostra só os
     dados daquele cliente. Se souber, me diz o nome (ex: `app.py`). Se não tiver nada assim, ou
     não souber, responde 'não sei' e eu procuro."
   - **P4** "Quais contas online sustentam este projeto? Só o nome do serviço, sem login nem senha.
     Exemplos: GitHub (onde o código fica guardado), Google (Drive, planilhas, e-mail), Microsoft
     (OneDrive), Meta (Business Manager), o serviço onde o app está hospedado."
   - **P5** "Existe outra pasta nesta máquina com código deste mesmo projeto? Exemplo comum: a
     pasta do painel de cliente baixada separada da pasta principal. Se sim, o caminho. Se não,
     'não'."

5. Gravar `.claude/seguranca-verificar.md` com este modelo (nunca escrever senha ou chave nele).
   Quando o arquivo de acesso estiver em outra pasta, gravar a pasta junto:

   ```
   # Configuração da skill seguranca-verificar (sem senha ou chave aqui, nunca)
   publicado: não | sim, em <serviço>
   credenciais_moram_em: arquivo .env | painel do serviço <qual> | dentro do código | não sei
   arquivo_de_acesso: nenhum | <caminho relativo à raiz do projeto> | <outra pasta> :: <caminho relativo a ela>
   contas: <lista>
   outras_pastas: nenhuma | <caminhos>
   ultima_revisao_de_contas: nunca
   ```

6. Rodar o Passo 1 completo. Se houver arquivo de acesso e o item 1.1 estiver limpo, perguntar "O
   arquivo <nome> está hoje do jeito que deveria, com o login e o acesso funcionando como você
   quer?" e, com o sim, criar a referência (Passo 1, `--baseline-criar`). Avisar: "Guardei só uma
   assinatura das linhas de segurança de <arquivo>, sem o texto. Da próxima vez eu comparo e aviso
   se algo mudou por fora."

## Gatilho

1. **Por mudança real** (principal): terminou de alterar código publicado, entrou senha ou chave
   nova, integração nova, dependência nova. Rodar como parte de fechar a tarefa, sem esperar
   pedido.
2. **A pedido da pessoa**, a qualquer momento.
3. **Revisão de contas a cada 90 dias**: o Passo 2 completo roda na primeira execução e sempre
   que `ultima_revisao_de_contas` tiver mais de 90 dias (ou for "nunca"). Nas demais rodadas,
   repetir só as perguntas do Passo 2 que ficaram pendentes.

Não rodar por calendário fixo sem fato novo: auditoria sem mudança vira achado inventado.

## Passo 1: camada de código (o script verifica)

Na pasta do projeto: `bash <pasta-da-skill>/verificar.sh`, com `--acesso <arquivo>` quando houver
arquivo de acesso configurado. Repetir com `--pasta "<caminho>"` pra cada entrada de
`outras_pastas` (caminho entre aspas, principalmente no Windows). O script imprime uma linha por
item, `ITEM|ESTADO|EVIDÊNCIA`, com estes itens:

| Item | O que confere | Estado do script → estado do relatório |
| --- | --- | --- |
| 1.1 | Senha ou chave escrita em arquivo rastreado (formatos conhecidos + atribuição genérica, com filtro de exemplo) | `CORRETO`/`PROBLEMA`/`ERRO` |
| 1.2 | O mesmo, no histórico inteiro do git, com os commits onde aparece | `PROBLEMA` = incidente: trocar a credencial primeiro |
| 1.3 | Arquivo de credencial rastreado (`.env`, `secrets.toml`, `credentials.json`, `token.json`, chave `.pem`, etc.) | idem |
| 1.4 | `.gitignore` cobrindo esses arquivos | `PROBLEMA` = propor as linhas e aplicar com confirmação |
| 1.5 | Dependência com versão exata (Python) ou lockfile (Node) | `INFO`: informativo, sem ação obrigatória |
| 1.6 | Hook `pre-commit` presente e varrendo segredo | `PROBLEMA` = apontar a skill `seguranca-instalarbarreiras` deste repositório (ou um verificador como gitleaks) |
| 1.7 | Integridade do arquivo de acesso contra a referência em hash, comparando a versão publicada (`origin/HEAD`, `main` ou `master`) ou, sem remoto acessível, a cópia local, dizendo qual | `PROBLEMA` = alerta: se a pessoa não reconhece a mudança, investigar antes de tudo; se reconhece, `--baseline-atualizar` |
| 1.8 | Arquivo de dado rastreado (csv, xlsx, pdf) que pode conter dado de cliente | `INFO`: pedir pra pessoa confirmar o conteúdo |
| 1.9 | Variável pública de frontend com nome sensível (vai pro navegador de qualquer visitante) | `PROBLEMA` |

Regras de leitura da saída:

- `NAO_SE_APLICA` (pasta sem git, sem arquivo de dependências) entra no relatório como tal, não
  como correto.
- A referência do 1.7 só é criada ou atualizada quando o 1.1 está limpo, e só com `--baseline-criar`
  (primeira vez) ou `--baseline-atualizar` (mudança que a pessoa confirmou que fez de propósito).
  Nunca atualizar por cima de um alerta que a pessoa não reconheceu: isso apaga a evidência.
- Problema em 1.1 ou 1.2: avisar a pessoa na hora, com arquivo e linha (nunca o valor), e a
  ordem fixa: trocar a credencial no serviço de origem, depois tirar do arquivo, e só então
  pensar em histórico. Onde se troca, pelos serviços mais comuns: Meta (Configurações do negócio >
  Usuários do sistema > gerar token novo), Google (Console > APIs e serviços > Credenciais), GitHub
  (Settings > Developer settings > tokens).

## Passo 2: camada de contas (só a pessoa confirma)

Nenhum destes itens é verificável daqui. Perguntar com o texto abaixo, com a dica de onde
conferir, e registrar a resposta como estado; sem resposta, o estado é "fora do alcance do
agente, pendente".

- "O repositório no GitHub está privado? Conferir: ao lado do nome do repositório aparece
  'Public' ou 'Private'. Se tem dado de cliente e está Public, isso é o primeiro item a resolver."
- "As contas que sustentam o projeto (<lista de `contas`>) têm verificação em duas etapas ligada?
  É aquela segunda confirmação no celular ou no aplicativo depois da senha. Conferir na área de
  segurança de cada conta. Se alguma não tem, essa é a ação de maior proteção disponível hoje,
  mais do que qualquer item desta lista."
- Se `publicado` for sim: "Quem consegue abrir o app publicado? Só quem você liberou, ou qualquer
  pessoa com o link? No Streamlit Cloud: Settings > Sharing. Na Vercel: Settings > Deployment
  Protection."
- "As planilhas ou arquivos que o app lê estão compartilhados só com pessoas ou contas específicas,
  ou com 'qualquer pessoa com o link'? Conferir: botão Compartilhar > Acesso geral. 'Qualquer
  pessoa com o link' numa planilha de resultado de cliente é o vazamento mais comum nesse tipo de
  projeto."
- "Alguém que saiu (cliente que encerrou, pessoa que deixou o time) ainda tem acesso a alguma
  coisa? Ex: e-mail liberado no painel, planilha compartilhada, link antigo que ainda funciona."
- Se houver chave de serviço ou API: "Quando foi a última vez que essa chave foi trocada por uma
  nova? Recomendação comum: a cada 90 dias."
- "O disco do computador está criptografado? No Windows: Configurações > Privacidade e segurança >
  Criptografia do dispositivo. No Mac: FileVault."

Ao terminar, gravar a data em `ultima_revisao_de_contas`.

## Passo 3: relatório

Primeira execução, e sempre que a pessoa pedir "relatório completo": tabela inteira. Nas
seguintes: só o que for achado real (problema, correção feita, pendência que só ela resolve). Sem
achado nenhum: uma linha ("verificação de segurança: nenhum achado nos N itens de código; M
pendências de conta seguem abertas").

| Item | Estado | Evidência ou pergunta |
| --- | --- | --- |
| 1.1 Segredo no estado atual | Verificado e correto | script: nenhum padrão de segredo nos arquivos rastreados |
| 1.4 `.gitignore` | Verificado e com problema | `.env` descoberto; corrigido com confirmação: linha `.env` adicionada |
| 1.7 Integridade | Verificado e correto | 4 linhas iguais à referência; fonte: versão publicada (origin/main) |
| 2.2 Duas etapas | Fora do alcance do agente | pendente: resposta da pessoa |

## O que esta skill não garante

Nomear isto é parte de não virar teatro: não protege contra falha desconhecida da plataforma, golpe
direcionado por e-mail ou mensagem, invasão da conta Google ou GitHub da pessoa por fora do projeto,
nem contra bloqueio de conta de anúncio por política da plataforma. O detector de segredo funciona
por formato conhecido: senha simples numa variável de nome inocente passa. O objetivo é reduzir
risco real e verificável, não prometer certeza.

## Checklist copiável

- [ ] Pasta confirmada com a pessoa antes de qualquer comando
- [ ] Configuração existe (`.claude/seguranca-verificar.md`); se não, Passo 0 com autorização
- [ ] `verificar.sh` rodado na pasta principal e em cada `outras_pastas`, com `--acesso` quando houver
- [ ] `ERRO` e `NAO_SE_APLICA` reportados como tal, nunca como correto
- [ ] Problema em 1.1 ou 1.2: pessoa avisada com arquivo e linha; ordem trocar → tirar → histórico
- [ ] Referência do 1.7 só criada/atualizada com 1.1 limpo e confirmação da pessoa
- [ ] Passo 2: completo na primeira vez ou após 90 dias; senão só as pendentes; data gravada
- [ ] Relatório no formato certo pro momento (completo ou só achados)
- [ ] Nenhum valor de senha ou chave apareceu no chat nem foi gravado em lugar nenhum
