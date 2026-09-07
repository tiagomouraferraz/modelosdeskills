# Textos falados da skill seguranca-verificar

Blocos que o assistente diz à pessoa, já no formato certo (tópicos curtos). Adaptar só o que
estiver entre `<...>`. O `SKILL.md` diz quando usar cada um; este arquivo só guarda o texto.

## Abertura (Passo 0.1)

"Oi! Sou seu assistente de segurança. Vou te ajudar a proteger este projeto contra os erros mais
comuns de quem usa IA sem ser programador, como:
- senha escrita onde não devia;
- arquivo de acesso ou de dado de cliente indo parar no lugar errado;
- mudança no login que ninguém percebeu;
- o próprio assistente com permissão pra agir sem te perguntar; entre outros.

São 10 verificações no código mais as perguntas sobre as suas contas. Nada aqui foi inventado:
cada checagem segue práticas usadas no mundo inteiro (OWASP, NIST, CIS Controls, orientações
oficiais do GitHub e a minimização de dados da LGPD). Se quiser, te mostro a base de cada item.
Não altero nada sem seu ok e não mostro nenhuma senha na tela.

A pasta aberta é `<caminho>`. Pelo que tem nela (`<dois ou três nomes>`), me parece um projeto de
<tipo>, e é nele que vou focar. Primeiro passo: olhar a pasta, só leitura, pra eu descobrir a
maior parte sozinho e te perguntar o mínimo. Nisso eu também procuro, nas suas pastas Documentos,
Área de Trabalho e Downloads, outra cópia deste projeto, e guardo um arquivo pequeno de
configuração na pasta (sem nenhuma senha dentro). Recomendo começar por aí. Se a pasta não for
essa, me avisa. Se estiver tudo certo, diga ok pra eu começar a olhar."

Pasta vazia ou só com os arquivos da skill: "Essa pasta parece ser a da própria skill (ou está
vazia). Abre o assistente na pasta do projeto que você quer proteger e me chama de novo."

Segunda execução (configuração já existe): "Oi de novo. Vou conferir a segurança do projeto
`<pasta>`, como da outra vez."

## Descoberta (Passo 0.3)

"Pronto. O que eu descobri:
- <tipo do projeto e serviço, ex: painel em Streamlit que lê planilhas do Google>;
- <onde o código fica, ex: sem endereço de repositório remoto nesta pasta; pelo caminho, a pasta
  não parece sincronizada>;
- <caminho de publicação, ex: o Streamlit Cloud só publica de um repositório no GitHub; sem
  remoto aqui, ou o painel não está no ar, ou existe outra cópia dele num repositório>;
- <arquivo de acesso, ex: o `app.py` faz o login e decide o que cada pessoa vê>;
- <credenciais, uma por serviço, ex: uma chave dentro de `config.py`, linha 2, que vamos resolver
  primeiro; a credencial do Google das planilhas não está nesta pasta>;
- <achado já visível, ex: `leads-agosto.csv` guardado no git, com colunas nome, e-mail e
  telefone: trato como dado real>;
- não encontrei outra cópia deste projeto em <pastas>, até <N> níveis.

Se algo não bater, me corrige. Senão, diga ok pra eu seguir com a verificação."

## Outra pasta e caminho de publicação (Passo 0.4)

Achou: "Encontrei `<caminho>`, que parece ser outra cópia deste projeto (<o que bateu>); sigo
verificando as duas, ok?"

Não achou: "Uma pergunta que eu não consigo responder olhando esta pasta: **existe outra pasta
neste computador com código deste mesmo projeto, e por onde ele vai pro ar?**
- **Pergunto porque** às vezes o código publicado fica numa pasta separada, e eu preciso
  verificar as duas; e correção que eu fizer aqui só vale no ar se for por esta pasta que o
  projeto é publicado.
- **Respostas mais comuns pra esta situação:** 'é só esta e eu publico daqui', 'tem outra com o
  código publicado', 'alguém publicou pra mim'.
- **Como descobrir:** se você baixou algum repositório do GitHub pra este projeto, ele está em
  outra pasta, com o nome do repositório; se alguém publicou pra você, essa pessoa sabe de onde.
- **O que faço com a resposta:** rodo a mesma verificação na outra pasta, e em cada correção te
  digo se ela já vale no ar ou se precisa republicar.
- **Se não souber:** sigo só com esta e anoto como pendente.

Diga ok pra eu seguir só com esta, ou me passa o caminho da outra pasta."

"Tem outra mas não lembro onde": "Sem problema: anotei 'outra pasta: pendente, localizar', no
topo da lista, porque é nela que costuma estar o git, um segredo guardado no histórico, e o
caminho de publicação. A busca nas pastas comuns não achou; o próximo passo é eu procurar na sua
pasta de usuário inteira, só leitura, pelos mesmos sinais (leva alguns minutos). Diga ok pra eu
procurar."

## Arquivo de acesso (Passo 0.6)

"Li o `<arquivo>`:
- **O que ele faz:** <duas frases em linguagem simples>.
- **Bate com a boa prática** de controle de acesso (OWASP A01 e menor privilégio do NIST):
  primeiro autenticar, depois mostrar só o que é daquela pessoa. <Ou, se um ponto depende do que
  não está na pasta: **Verificado parcialmente:** o login antes de tudo bate com a boa prática; já
  <X> não está em nenhum arquivo desta pasta, então <Y> eu não consigo confirmar daqui; conferir
  onde mora entra no topo da sua lista.>
- <Se houver ponto estranho: **Um ponto me chamou atenção:** X, que significa Y.>
- **Recomendo** guardar uma assinatura dessas linhas, sem o texto, pra te avisar se algo mudar
  por fora. Ela cobre só as linhas que falam de login e acesso; mudança em outra linha não
  dispara alerta, então revisar o arquivo depois de qualquer alteração continua necessário.

Diga ok pra eu guardar."

## Item 1.1: segredo no código

Primeira mensagem, com a pergunta do serviço no formato da regra 3:

"**Uma chave escrita em `<arquivo>`, linha <N>**, numa variável chamada `<nome>`.
- **Por que importa:** qualquer pessoa com acesso ao arquivo, ou ao git, tem a chave.
- **Ordem certa:** (1) você troca a chave no serviço; (2) eu tiro do arquivo; (3) histórico.
  Trocar é gerar a nova e **revogar a antiga**; gerar sozinho não invalida a que está exposta.

Antes, uma pergunta: **de qual serviço é essa chave?**
- **Pergunto porque** a troca é feita lá, e o nome `<nome>` não diz.
- **Respostas mais comuns pra esta situação:** 'Meta Ads', 'Google', 'outro'.
- **Como descobrir:** onde você gerou a chave quando montou o projeto.
- **O que faço com a resposta:** te passo o caminho exato pra trocar.
- **Se não souber:** anoto como pendente e sigo.

Me diz de qual serviço é, ou diga ok pra eu anotar como pendente e seguir."

Segunda mensagem, com o caminho do serviço (seção "Trocar uma credencial"):

"<Serviço>, então. A troca fica com você:
- <caminho da troca, com 'revogar/invalidar a antiga' em negrito>;
- guarda a nova em lugar seguro por enquanto; no fim eu te digo onde e em que formato colar.
- **Efeito esperado:** revogar derruba na hora qualquer cópia do app que esteja no ar com a chave
  antiga. Se está publicado, ele para até receber a chave nova no cofre e ser republicado. Isso é
  o certo; só não te pega de surpresa.

Me diz se o app está no ar (se não souber, sigo assim mesmo e anoto), e diga 'troquei' quando
tiver feito, que eu tiro a chave do arquivo. Se preferir que eu tire agora, antes da troca, diga
'pode parar o app'."

Depois do "troquei": "Anotado: chave de <serviço> trocada hoje, segundo você (eu não vejo o
painel do serviço, então registro como sua informação). Feito: `<arquivo>` agora lê de
<cofre> (reli o arquivo: <evidência>). <Se o caminho de publicação não for esta pasta: a mudança
aqui só vale no ar depois de republicar por <caminho>.> Pendente sua, no topo: colar a chave nova
no cofre; formato no fim."

## Trocar uma credencial (caminhos por serviço)

Telas mudam com o tempo; o princípio não. Dizer só o caminho do caso encontrado, nunca prometer
tempo ("um minuto").

- **Meta:** Configurações do negócio > Usuários do sistema > gerar token novo e **invalidar o
  antigo**.
- **Google:** Console > APIs e serviços > Credenciais > criar chave nova e **excluir a antiga**.
- **GitHub:** Settings > Developer settings > tokens > **delete** o antigo.
- **Supabase:** Project Settings > API. Chaves novas (valor começa com `sb_secret_` ou
  `sb_publishable_`): criar uma nova e **revogar** a antiga, uma a uma. Chaves legadas (valor
  começa com `eyJ`): "rotate JWT secret" troca também a chave pública do site, que para de
  funcionar até ser republicado com as duas novas; caminho menos disruptivo, quando o painel
  oferecer: criar as chaves novas, republicar com elas, e só então desativar as legadas.
- **Formato não reconhecido** (o assistente já leu o valor e não bateu com nenhum; não pedir pra
  pessoa reler), pergunta no formato da regra 3: "No painel do Supabase, em Project Settings >
  API, qual chave é igual à do seu `.env`: uma 'secret' (chaves novas) ou a 'service_role' da aba
  Legacy?" A pessoa responde comparando, sem colar valor.
- Serviço que não permite revogar individualmente: dizer isso e o que muda.

## Item 1.2 e 1.8: histórico, depois da troca

Sem remoto, as duas perguntas prévias, uma por vez (formato da regra 3):

1. "**Este projeto já foi enviado pra algum lugar (GitHub, outro computador, alguém)?**" Pergunto
   porque se já foi, a chave antiga e o dado já saíram daqui. Comuns: 'nunca enviei', 'sim, está
   no GitHub'. Como descobrir: se você já abriu esse projeto em github.com, foi enviado. Se não
   souber: trato como enviado, o caminho mais seguro.
2. "**Esta pasta entra em algum backup ou sincronização (OneDrive, Google Drive, Dropbox, Time
   Machine)?**" Pergunto porque pelo caminho ela não parece, mas o Google Drive pra computador
   sincroniza qualquer pasta sem mudar o caminho. Como descobrir: ícone de nuvem ou de check ao
   lado da pasta no Explorador de Arquivos. Se não souber: trato como sincronizada.

Sem remoto e os dois "não":

"A chave antiga (e/ou o arquivo de dado) continua no histórico local do projeto, o registro de
versões que o git guarda.
- **O risco concreto:** o primeiro envio pro GitHub levaria tudo junto.
- **O que eu consigo fazer:** recomeçar esse histórico a partir dos arquivos de hoje, já limpos.
  Você não perde nenhum arquivo, mas perde a possibilidade de voltar a versões antigas (hoje são
  <N> versões).
- **Cópia antes:** faço uma cópia da pasta em `<caminho fixo>` (fora de qualquer sincronização),
  que fica com o histórico antigo dentro (<a chave antiga, a lista de leads>). Se no fim da
  conversa a verificação bater, eu apago a cópia, com seu ok, antes de fechar.
- **Recomendo**, antes de qualquer envio.

Diga ok pra eu recomeçar o histórico, ou 'depois' pra eu anotar como pendente antes do primeiro
envio."

Com remoto:

"A chave antiga continua no histórico do projeto, mas já não abre nada; o que fica é um rastro.
- **Opção 1, deixar como está.** Risco: se o repositório for ou virar público, qualquer pessoa vê
  que existiu uma chave ali; com ela trocada, o dano é pequeno.
- **Opção 2, limpar o histórico**, que é reescrever o passado do projeto e forçar o envio pro
  GitHub. Risco: feito errado, perde trabalho ou quebra a cópia de quem mais tiver o projeto; é
  operação que eu não faço por você e que precisa de backup antes.
- **Não existe certo ou errado**, só o risco que você escolhe.
- **Recomendo:** repositório privado que vai continuar privado, deixar e anotar; público ou com
  chance de virar, limpar pelo passo a passo oficial do GitHub ('Removing sensitive data from a
  repository'), com backup.

Diga ok pra eu seguir com a recomendação, ou me diz o que prefere." Pro arquivo de dado (1.8),
o risco é a LGPD, não uma chave.

## Item 1.8: dado de cliente no git

"**`<arquivo>` está guardado no git.**
- **Por que importa:** colunas <nome, e-mail, telefone>; qualquer pessoa com acesso ao
  repositório teria a lista (LGPD, princípio da necessidade).
- **O que eu consigo fazer agora:** deixar o arquivo fora do git (ele continua na sua pasta) e
  colocar `<arquivo>` no `.gitignore`, a lista do que o git deve ignorar.
- **E fora do git:** o arquivo continua na pasta, e vai junto se a pasta for copiada ou
  sincronizada. Recomendo guardar fora da pasta do projeto, ou apagar quando não precisar mais;
  mover é com você, eu anoto.
- **Recomendo**, mesmo que os dados sejam de teste.

Diga ok pra eu tirar do git e proteger."

Depois, a decisão: "Uma decisão a mais, porque a proteção de commit que vou propor barra senha,
não arquivo de dado:
- **Opção 1:** ignorar só este arquivo. Risco: o próximo `<leads-setembro.csv>` entra no git sem
  aviso.
- **Opção 2:** nenhum csv ou xlsx desta pasta entra no git daqui pra frente. Risco: se um dia
  você quiser versionar uma planilha de propósito, precisa liberar.
- **Não existe certo ou errado, existe o risco que você escolhe assumir; recomendo a 2**, porque
  esta pasta recebe exportação de leads.

Diga ok pra eu aplicar a 2, ou 'só este'."

## Pasta sincronizada na nuvem

"**A pasta do projeto está dentro do <OneDrive>.**
- **Por que importa:** o <OneDrive> envia a pasta inteira pra nuvem, inclusive o `.env` (o arquivo
  das senhas) e <arquivos de dado>. Não é erro seu, é como ele funciona; mas quem entrar na sua
  conta <Microsoft> tem as senhas e os dados.
- **Opção 1, manter aqui**, proteger a conta <Microsoft> com verificação em duas etapas, e eu movo
  o `.env` e <os arquivos de dado> pra `<pasta fora da sincronização>`. Custo: sem o `.env` na
  pasta, o app não roda mais neste computador até ele voltar; se ele já roda publicado, as
  variáveis moram no painel e o arquivo local pode ser dispensado.
- **Opção 2, mover a pasta do projeto inteira pra fora.** Risco: <sem git nem outra cópia
  confirmada, a sincronização é o único backup do projeto; mover é ficar sem backup | ganha que
  senha e dado param de ir pra nuvem, perde o backup automático>.
- **Não existe certo ou errado, existe o risco que você escolhe assumir; recomendo a <1|2>**,
  porque <não há outra cópia do projeto | existe cópia confirmada em <remoto>>. Nos dois casos, o
  que já subiu continua no histórico de versões do serviço até você apagar lá.

Diga ok pra eu <mover os dois arquivos (opção 1)>, ou '<manter tudo | mover>' pra eu só anotar."

## Item 1.6: proteção de commit

"Nada impede hoje que uma senha entre no git de novo, como aconteceu com `<arquivo>`.
- **O que eu consigo fazer agora:** instalar uma proteção mínima, um verificador pequeno que roda
  a cada commit, inclusive fora do assistente, e bloqueia senha, chave ou arquivo de credencial.
- **O que muda no projeto:** um único arquivo na pasta do git, removível a qualquer momento.
- **Recomendo**, porque é a proteção que mais evita erro sem depender de você lembrar de nada.

Diga ok pra eu instalar."

## Item 1.9: variável pública, em duas mensagens

Primeira (só o que o ok faz):

"Uma variável com nome de chave de serviço está marcada como pública em `<arquivo:linha>`.
- **Por que importa:** tudo que leva o prefixo público (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`)
  vai pro navegador de qualquer visitante; se o site está no ar, a chave está exposta agora.
- **O que eu faço com o seu ok:** mudo o código pra gravação acontecer no servidor, sem chave
  nenhuma no navegador. Só nesta pasta; nada no <serviço> nem na hospedagem. É mudança de
  funcionamento, então teste o formulário depois de republicar<, e como não sei por onde o site é
  publicado, a mudança só vale no ar depois de republicar por lá>.

Diga ok pra eu mudar o código agora, ou 'depois'."

Segunda, depois da resposta:

"Agora a chave em si, que é o primeiro item da sua lista.
- **O que corta o risco é revogar a chave exposta no <serviço>**, gerando uma nova antes. Gerar
  sem revogar não resolve, e apagar a variável no painel da hospedagem também não, porque as
  versões publicadas continuam com a chave antiga. Revogar derruba o site até ele ser republicado
  com a chave nova numa variável **sem** prefixo (Vercel: Settings > Environment Variables); é o
  efeito esperado, e site fora do ar é dano menor que banco aberto.
- <Caminho da troca pelo caso encontrado, ou a pergunta de formato não reconhecido, da seção
  "Trocar uma credencial".>
- **Custo de esperar:** enquanto a chave antiga existir, qualquer visitante pode ler ou apagar os
  leads; se tem tráfego pago apontando pra essa página, vale pausar até trocar.

Diga 'troquei' quando tiver revogado, ou 'depois' pra eu anotar como urgente."

Adiado: "Anotado como urgente, adiado por decisão sua, no topo. Uma vez só: enquanto isso, os
leads dessa página estão ao alcance de qualquer visitante; se houver tráfego pago apontando pra
ela, considere pausar. Sigo."

## Item 1.10: o próprio assistente

Modo já com confirmação: "Seu modo já pede confirmação (Auto: no que o filtro julga sensível;
padrão: em tudo): item correto."

Modo sem confirmação:

"Uma proteção que não está no seu código, mas no jeito de usar o assistente: o modo de permissão.
- **No modo que executa sem confirmar** ('Bypass' no Claude Code), eu faço tudo sem te perguntar,
  o que inclui erro meu ou uma instrução escondida em algo que eu leia.
- **Pra onde ir:** no modo padrão, eu peço seu ok pra tudo que altera algo; no modo Auto, um
  filtro automático aprova sozinho o rotineiro e só pergunta o que ele julga sensível (mais
  cômodo, um pouco menos conservador). Qualquer um dos dois resolve; o padrão é o mais seguro.
- **Como trocar:** no Claude Code, Shift+Tab até aparecer Auto ou padrão no rodapé, ou o seletor
  de modo da extensão do VS Code; em outra ferramenta, a configuração de aprovação dela.

Recomendo trocar agora; me diz quando tiver trocado."

Fora do Claude Code, sem conseguir ler a configuração, pergunta no formato da regra 3: "**O
<Cursor> está configurado pra pedir sua confirmação antes de agir, ou pra rodar sem perguntar?**"
Pergunto porque no modo sem confirmação um erro meu, ou uma instrução escondida, executa sem você
ver. Comuns: 'pede confirmação', 'roda sem perguntar'. Como conferir: <caminho da tabela de
Portabilidade>. O que faço: ligada, recomendo desligar; desligada, item correto. Se não souber:
pendente com esse caminho.

Conectores: "Ferramentas conectadas que agem no mundo real e que eu vejo nesta sessão: <lista
real>. Eu consigo colocar cada uma inteira na lista de aprovação manual do projeto, que obriga
confirmação mesmo no modo Auto (até pra ler, um custo pequeno), sem mexer no que já estiver
configurado. Recomendo, porque um erro meu, ou uma instrução escondida em algo que eu leia, não
chega a agir fora daqui sem você ver. Diga ok pra eu configurar." Fora do Claude Code, com os
arquivos de MCP lidos e vazios: "pelos arquivos, nenhuma integração ligada; se você ligou alguma
pelo painel (ex: a do Supabase, que executa comandos direto no banco), me diz, porque essa é a que
mais importa."

## Passo 3: o que o assistente tenta antes, e as perguntas

Antes das perguntas, uma linha por tentativa:
- `gh` ausente: "Tentei a ferramenta oficial do GitHub (`gh`): não está instalada. Com ela eu
  conferia sozinho se existe um repositório deste projeto e se ele é privado <e provavelmente
  achava a outra pasta>; ela dá ao assistente leitura e escrita na sua conta GitHub, então é mais
  alcance e mais risco junto. Se quiser: instala pela página cli.github.com e me chama, que eu
  disparo o login e você só segue as telas do navegador. Recomendo só com o modo de confirmação
  ligado. Por ora vira pergunta."
- Drive ligado: "**Posso consultar seu Drive, só leitura, pra ver com quem a planilha do app está
  compartilhada?** É o único uso; nada é alterado. Diga ok, ou 'não' pra eu perguntar em vez de
  olhar."
- Disco: "Tentei conferir a criptografia do disco (`manage-bde -status`): falhou, precisa de
  administrador, que eu não tenho. Abrir o editor 'como administrador' me daria isso, mas dá ao
  assistente mais poder sobre o sistema inteiro; não recomendo só pra isso, e fica como pergunta."

Cabeçalho da mensagem de perguntas: "Esta mensagem é longa de propósito: são as perguntas que só
você responde, e cada uma pede abrir um painel. Responde as que souber, na ordem; as outras eu
anoto como pendentes com o caminho pra conferir, e você pode me responder uma por vez, depois,
quando abrir cada painel." Fecho: "Diga ok pra eu anotar todas como pendentes e seguir."

Perguntas (cada uma com "por que importa", "como conferir" e "se não souber: pendente"; adaptar
à pilha real; exemplos de Streamlit com planilha Google e Next.js com Supabase):

1. Se houver remoto, sinal de hospedagem que publica de repositório, ou outra pasta pendente: "O
   código deste projeto está num repositório no GitHub? Se sim, ele está privado?" Por que
   importa: com dado de cliente ou chave no código, Private é o mínimo. Conferir: ao lado do
   nome aparece Public ou Private.
2. "As contas que sustentam o projeto (<lista, com GitHub 'se o app estiver no ar' quando a
   hospedagem publica de repositório>) têm verificação em duas etapas, de preferência por
   aplicativo autenticador ou chave de acesso (passkey: entrar com o desbloqueio do próprio
   celular ou computador), não por SMS?" Por que importa: é a proteção que mais evita conta
   invadida, mais do que qualquer item desta lista; SMS cai em golpe de troca de chip. Conferir:
   Google, myaccount.google.com > Segurança; Meta, Configurações > Segurança e login; GitHub,
   Settings > Password and authentication; Vercel, Settings > Authentication; Supabase, Account >
   Security; Microsoft, account.microsoft.com > Segurança.
3. Se houver sinal ou confirmação de app publicado: "Quem consegue abrir o app publicado: só quem
   você liberou, ou qualquer pessoa com o link?" Streamlit Cloud: Settings > Sharing. Vercel:
   Settings > Deployment Protection. Site público de propósito: "e o painel da hospedagem, só
   você entra?".
4. "Onde o app guarda ou lê dado de cliente, quem consegue acessar?" Planilha Google: Compartilhar
   > Acesso geral, nunca "qualquer pessoa com o link". Supabase: a tabela de leads tem regras de
   acesso por linha (RLS) ligadas, pra chave pública do navegador não ler nem apagar tudo? Dizer
   junto: RLS protege contra a chave pública; contra uma chave de serviço exposta, só a troca.
5. "Alguém que saiu (cliente que encerrou, pessoa do time) ainda tem acesso a algo?" E-mail
   liberado no painel, planilha compartilhada, link antigo.
6. Pra cada credencial da configuração: "Quando a credencial de <serviço> foi trocada pela última
   vez?" Recomendação: a cada 90 dias. A trocada hoje, segundo a pessoa, entra com a data e sai
   da pergunta.
7. "O disco do computador está criptografado?" Windows: Configurações > Privacidade e segurança >
   Criptografia do dispositivo. Mac: FileVault.

## Passo 4: encerramento

Pendência de chave nova (item 2 do resumo): "Colar a chave nova de <serviço> no cofre. No arquivo
`<.streamlit/secrets.toml>` da pasta: <formato exato>. Se o app estiver no ar, o mesmo texto em
<Settings > Secrets>, **acrescentado no fim do que já está lá, sem apagar nada** (<a seção `[auth]`
do login mora ali>); depois, republicar. Se o app não rodar depois de colar, me chama antes de
mexer em qualquer coisa."

Repetição a cada 30 dias:

"Segurança envelhece: dependência nova, arquivo novo, alguém que sai.
- **Recomendo** que esta verificação se repita a cada 30 dias.
- **O jeito seguro:** um lembrete que roda quando você abre o assistente neste projeto; se
  passaram 30 dias, eu aviso e proponho rodar, e você diz ok. Nada roda sem você presente, de
  propósito: automação que age sem ninguém olhando é o tipo de acesso que, num erro meu, ninguém
  pega a tempo.
- **O que muda no projeto:** uma linha no arquivo de instruções (`CLAUDE.md` no Claude Code,
  `AGENTS.md` nas outras ferramentas; criado se não existir) e a data de cada verificação gravada
  na configuração.

Diga ok pra eu configurar." Linha a gravar: "No início de toda sessão, ler
`.seguranca-verificar/config.md`; se `ultima_verificacao` tiver mais de 30 dias, avisar e propor
rodar /seguranca-verificar."

Complemento nativo (só Claude Code, só projeto com código-fonte): "O Claude Code tem um comando
próprio, `/security-review`, que revisa o código em si (o que esta skill não faz): procura
vulnerabilidade no que foi programado. Recomendo rodar depois desta verificação. Diga ok pra eu
rodar agora, ou deixa pra outra hora."

Estrela (só quando a skill foi útil, primeira vez):

"Se isto te ajudou, uma estrela no repositório ajuda outras pessoas a encontrarem a skill. É o
jeito que o GitHub tem de mostrar que algo é útil; não custa nada e não te compromete com nada.
- Abre https://github.com/tiagomouraferraz/modelosdeskills no navegador.
- Se não estiver logado, entra na sua conta do GitHub (ou crie uma gratuita em
  github.com/signup).
- No alto da página, à direita, clica uma vez no botão com a estrela e a palavra 'Star'. Ele
  muda pra 'Starred' e pronto.

Compartilhe a skill com um colega e diga como ela ajudou o seu projeto. Ajude outras pessoas a
deixarem os seus projetos seguros."

Apagar a cópia do histórico: "A cópia com o histórico antigo: a verificação bateu (<evidência>),
então ela já não serve pra nada e guarda <a lista de leads e a chave antiga>. Diga ok pra eu
apagar `<caminho>`."

Commit final: "Pra nada ficar pela metade, eu registro as mudanças de hoje no git do projeto (uma
foto do estado atual, só local, sem enviar pra lugar nenhum). Diga ok pra eu registrar."

## Vocabulário mínimo (usar na primeira vez que o termo aparecer)

- **git:** o registro de versões da pasta do projeto, que guarda cada "foto" salva.
- **commit:** uma dessas fotos.
- **histórico:** todas as fotos, inclusive antigas; apagar um arquivo hoje não apaga ele das
  fotos antigas.
- **versionado / rastreado:** incluído nas fotos.
- **remoto / GitHub:** a cópia do registro guardada num servidor, pra onde o "envio" (push) vai.
- **cofre:** o lugar onde a plataforma guarda senha e chave fora do código.
- **passkey:** entrar com o desbloqueio do próprio celular ou computador, em vez de senha.
