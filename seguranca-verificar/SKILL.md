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

## Tom de conversa (vale pra skill inteira)

A pessoa do outro lado não programa e pode estar usando isto pela primeira vez. Falar como um
assistente de segurança conversando, não como um relatório: uma ideia por mensagem, sem termo
técnico sem explicação de meia linha, sempre dizendo o que vai acontecer antes de acontecer, e
terminando cada passo com uma pergunta clara do que a pessoa precisa fazer. Se a pessoa parecer
perdida, explicar de novo com exemplo, sem pressa. Nunca listar comandos pra ela digitar.

## Passo 0: primeira execução (configuração guiada)

Se `.claude/seguranca-verificar.md` não existir na raiz do projeto, fazer esta configuração. Se
existir, cumprimentar em uma linha ("Oi de novo. Vou conferir a segurança do projeto <nome da
pasta>, como da outra vez.") e ir direto pro Passo 1.

1. **Abrir a conversa**, antes de qualquer comando:

   "Oi! Sou seu assistente de segurança. Vou te ajudar a proteger este projeto contra os erros
   mais comuns de quem usa IA sem ser programador: senha escrita onde não devia, arquivo de
   acesso indo parar no lugar errado, e mudança no login que ninguém percebeu. Nada aqui foi
   inventado: cada checagem segue práticas de segurança consolidadas e usadas no mundo inteiro
   (OWASP, NIST, CIS Controls, orientações oficiais do GitHub e o princípio de minimização de
   dados da LGPD). Se quiser, te mostro qual base sustenta cada item. Não vou alterar nada do
   seu projeto e não vou mostrar nenhuma senha na tela. Primeiro preciso confirmar uma coisa: a
   pasta aberta agora é `<caminho da pasta atual>`. É esse o projeto que você quer verificar?"

   Se a pessoa pedir as bases, mostrar a seção "Em que cada checagem se baseia" deste arquivo em
   linguagem simples, item por item, sem inflar: são práticas reconhecidas implementadas de forma
   simplificada, não uma certificação nem cobertura completa desses padrões.

   Se a pasta parecer errada (vazia, ou contendo só os arquivos desta skill), dizer isso de forma
   simples: "Essa pasta parece ser a da própria skill, não a do seu projeto. Abre o Claude Code na
   pasta do projeto que você quer proteger e me chama de novo com /seguranca-verificar." Pasta
   errada é o único jeito de esta skill produzir resultado enganoso, por isso a confirmação vem
   antes de tudo.

2. **Pedir uma única autorização pra olhar a pasta.** Pressupor que a pessoa não sabe nada sobre
   o próprio projeto e que tudo foi feito confiando na IA. Por isso o assistente descobre sozinho
   tudo que der, e só pergunta o resto.

   "Ótimo. Antes de qualquer pergunta, deixa eu olhar a pasta do projeto: só leitura, não mudo
   nada e não mostro nenhuma senha. Com isso eu mesmo descubro a maior parte do que preciso e só
   te pergunto o que não dá pra ver por aqui. Posso olhar?"

3. **Depois do sim:** avisar "Olhando agora, leva alguns segundos." e rodar
   `verificar.sh --inspecionar` **e** `verificar.sh` (a verificação completa, ainda sem arquivo de
   acesso). Com as duas saídas, deduzir o máximo e **contar o que descobriu em linguagem
   simples**, antes de perguntar qualquer coisa. Exemplo de resumo:

   "Pronto. O que eu descobri: o projeto é um painel feito em Streamlit, que lê planilhas do
   Google; o código fica guardado no GitHub; o arquivo `app.py` é o que faz o login e decide o
   que cada pessoa vê; e já encontrei uma chave escrita dentro de `config.py`, na linha 2, que
   vamos resolver daqui a pouco. Faltam só duas coisas que eu não consigo ver daqui."

   Como deduzir cada dado:
   - **Publicado e onde:** `sinais_de_app_publicado` e `servicos_detectados_no_codigo` (Streamlit,
     Vercel, Netlify). Sem sinal: propor "parece que nada está no ar" e confirmar.
   - **Onde moram as credenciais:** `arquivos_de_credencial_na_pasta` (tem `.env` = arquivo local);
     item 1.1 com problema = "dentro do código"; nenhum dos dois + serviço de hospedagem detectado
     = provavelmente no painel do serviço, confirmar.
   - **Arquivo de acesso:** `candidatos_a_arquivo_de_acesso`. Um candidato só: propor. Vários:
     mostrar os nomes e explicar como reconhecer ("é o arquivo que faz login e filtra o que cada
     pessoa vê; num painel, costuma ser o principal, tipo `app.py`"). Nenhum: "parece não ter
     controle de acesso; se o app é aberto pra qualquer um com o link, isso vira um item de
     atenção".
   - **Contas que sustentam o projeto:** `servicos_detectados_no_codigo` mais GitHub se houver
     remoto. Apresentar a lista deduzida e perguntar só "falta alguma?".

4. **Perguntar só o que sobrou, uma pergunta por vez, sempre com as quatro partes:** por que
   estou perguntando, quais as respostas mais comuns, como você descobre a sua, e o que eu faço
   com a resposta. "Não sei" é sempre resposta válida: leva a um caminho guiado de descoberta ou
   vira item pendente, e a varredura continua. Nunca travar esperando.

   O que costuma sobrar, e o texto de cada uma:

   - **Confirmar o que foi deduzido** (publicado, credenciais, arquivo de acesso, contas): "Eu
     deduzi X. Bate com o que você lembra? Se não souber, tudo bem: eu sigo com X e marco pra
     conferir depois."
   - **Outras pastas** (não dá pra descobrir olhando esta): "Pergunto porque às vezes o código de
     um painel publicado fica numa pasta separada da pasta principal do projeto, e eu preciso
     verificar as duas. As respostas comuns: 'não, é só esta' ou 'sim, tem outra pasta com o
     código do painel'. Como descobrir: se você já clonou ou baixou algum repositório do GitHub
     pra este projeto, ele está em outra pasta; procure no Explorador por uma pasta com o nome do
     repositório. Se não souber, eu sigo só com esta pasta e deixo anotado pra você conferir."
   - **Quem consegue abrir o app publicado** (só se houver app): "Pergunto porque um painel com
     dado de cliente aberto pra qualquer pessoa com o link é o vazamento mais comum. As respostas
     comuns: 'só quem eu liberei' ou 'qualquer pessoa com o link'. Como descobrir, no Streamlit
     Cloud: entra no painel do app, Settings, Sharing; na Vercel: Settings, Deployment
     Protection. Se você me disser o que está marcado lá, eu te digo se está do jeito certo."

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

6. Avisar "Configuração guardada. Agora te mostro o resultado da varredura item por item, com o
   que está bem e o que precisa de atenção, e vamos resolver um de cada vez." e seguir pro Passo 3
   com o resultado já obtido no item 3 (rodar de novo com `--acesso` se um arquivo de acesso foi
   confirmado). Se houver arquivo de acesso e o item 1.1 estiver limpo, perguntar "O
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

Nenhum destes itens é verificável daqui. Perguntar uma de cada vez, com o texto abaixo e as
quatro partes (por que pergunto, respostas comuns, como conferir, o que faço com a resposta), e
registrar a resposta como estado. "Não sei" vira "fora do alcance do agente, pendente", com a
instrução de como conferir repetida no relatório, e a conversa segue pra próxima pergunta.

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

Apresentar como conversa: uma frase de resumo primeiro ("Terminei. Encontrei 3 pontos de atenção
e 5 itens em ordem; vamos pelos que importam."), depois a tabela, depois **um item de cada vez**
pra resolver, começando pelo mais grave, sempre com a pergunta do que a pessoa quer fazer.
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

## Em que cada checagem se baseia

Fontes reconhecidas pela comunidade de segurança e de desenvolvimento. O script implementa cada
prática de forma simplificada, pro contexto de quem não programa; não substitui os padrões nem
certifica conformidade com eles.

| Checagem | Prática e fonte |
| --- | --- |
| 1.1, 1.2 Segredo em código ou no histórico | Credencial nunca no código: OWASP Top 10 (A02, falhas criptográficas; A05, configuração insegura), OWASP Secrets Management Cheat Sheet, fraqueza catalogada CWE-798 (credencial embutida no código), Twelve-Factor App, fator III (configuração em variável de ambiente) |
| 1.2 Trocar a credencial antes de limpar o histórico | Orientação oficial do GitHub, "Removing sensitive data from a repository": o segredo já vazou; revogar e gerar um novo vem antes de qualquer limpeza |
| 1.3, 1.4 Arquivo de credencial rastreado ou fora do `.gitignore` | Mesmas fontes de 1.1, aplicadas ao controle de versão; prática padrão de ferramentas como gitleaks, git-secrets e o secret scanning do GitHub |
| 1.5 Dependência com versão fixada | OWASP Top 10 (A06, componentes vulneráveis e desatualizados); orientação de dependências fixadas e lockfile de pip, npm e do framework SLSA de cadeia de suprimento |
| 1.6 Proteção de commit (hook `pre-commit`) | Detecção de segredo antes do commit: OWASP Secrets Management Cheat Sheet (detecção), push protection do GitHub, ferramentas gitleaks, git-secrets e detect-secrets |
| 1.7 Integridade do arquivo de acesso contra referência | Monitoramento de integridade de arquivo: NIST SP 800-53, controle SI-7 (integridade de software e informação); PCI DSS, requisito 11.5 |
| 1.8 Arquivo de dado de cliente rastreado | Minimização de dados: LGPD, art. 6º, princípio da necessidade; GDPR, art. 5º(1)(c); CIS Controls v8, controle 3 (proteção de dados) |
| 1.9 Variável pública de frontend com nome sensível | Tudo que vai pro navegador é público: OWASP (exposição de dado no cliente); documentação da Vercel e do Next.js sobre variáveis `NEXT_PUBLIC_` |
| 2 Verificação em duas etapas | NIST SP 800-63B (autenticação; preferir método resistente a phishing) e orientação da CISA pra pequenas empresas |
| 2 Repositório privado, app com acesso restrito, planilha não pública | Menor privilégio e controle de acesso: NIST SP 800-53, controles AC-3 e AC-6; CIS Controls v8, controles 3 e 6 |
| 2 Acesso de quem saiu removido | Gestão de contas: NIST SP 800-53, controle AC-2; CIS Controls v8, controle 5 |
| 2 Rotação de chave a cada ~90 dias | Recomendação da documentação do Google Cloud pra chave de conta de serviço; prática geral de rotação de credencial (OWASP Secrets Management) |
| 2 Disco criptografado | CIS Controls v8, controle 3.6 (criptografia em dispositivo de usuário final); orientação da CISA |
| Três estados, nunca "está tudo OK" | Princípio de auditoria com evidência: NIST SP 800-53A (avaliação por exame, entrevista e teste; sem evidência, não há conformidade) |

## O que esta skill não garante

Nomear isto é parte de não virar teatro: não protege contra falha desconhecida da plataforma, golpe
direcionado por e-mail ou mensagem, invasão da conta Google ou GitHub da pessoa por fora do projeto,
nem contra bloqueio de conta de anúncio por política da plataforma. O detector de segredo funciona
por formato conhecido: senha simples numa variável de nome inocente passa. O objetivo é reduzir
risco real e verificável, não prometer certeza.

## Checklist copiável

- [ ] Pasta confirmada com a pessoa antes de qualquer comando
- [ ] Configuração existe (`.claude/seguranca-verificar.md`); se não, Passo 0: olhar primeiro
      (uma autorização), contar o que descobriu, perguntar só o resto com as quatro partes
- [ ] `verificar.sh` rodado na pasta principal e em cada `outras_pastas`, com `--acesso` quando houver
- [ ] `ERRO` e `NAO_SE_APLICA` reportados como tal, nunca como correto
- [ ] Problema em 1.1 ou 1.2: pessoa avisada com arquivo e linha; ordem trocar → tirar → histórico
- [ ] Referência do 1.7 só criada/atualizada com 1.1 limpo e confirmação da pessoa
- [ ] Passo 2: completo na primeira vez ou após 90 dias; senão só as pendentes; data gravada
- [ ] Relatório no formato certo pro momento (completo ou só achados)
- [ ] Nenhum valor de senha ou chave apareceu no chat nem foi gravado em lugar nenhum
