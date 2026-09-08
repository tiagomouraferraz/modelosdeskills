# seguranca-verificar

Skill de verificação de segurança pra projeto feito com assistente de IA por quem não programa. Criada e testada no Claude Code; escrita pra funcionar em qualquer assistente que leia instrução e rode shell.

## Como instalar

1. Baixe o zip na aba Releases do repositório.
2. Descompacte dentro de `~/.claude/skills/` (Windows: `C:\Users\SEU-USUARIO\.claude\skills\`).
   A pasta `seguranca-verificar` já vem com o nome certo. Se a pasta `skills` não existir, crie com esse nome. No Windows, ao usar "Extrair tudo", apague o final do caminho de destino (o nome do zip, que o Windows acrescenta sozinho) pra não ficar `seguranca-verificar` dentro de outra `seguranca-verificar`. O resultado certo é `skills` > `seguranca-verificar` > `SKILL.md`.
3. Abra o assistente na pasta do seu projeto e chame `/seguranca-verificar` (no Claude Code) ou peça "use a skill seguranca-verificar". Em outra ferramenta: Codex lê a mesma pasta em `.agents/skills/` do projeto; ferramenta sem suporte a skill usa o conteúdo do `SKILL.md` como regra do projeto, com `textos.md`, `bases.md` e `verificar.sh` na mesma pasta. Na primeira vez ela
   se apresenta, confirma a pasta, pede uma autorização pra olhar o projeto, descobre sozinha o que
   der (onde o app está publicado, onde as senhas moram, qual arquivo controla o login, quais contas
   sustentam o projeto) e só pergunta o que não dá pra ver por ali, explicando por que pergunta e
   como você descobre a resposta. "Não sei" é sempre resposta válida.

## Isto é pra você?

Uma pergunta resolve: **a pasta do projeto está no seu computador?**

- **Está, e você usa Claude Code, Codex, Cursor ou Gemini CLI** — é pra você, e funciona inteira:
  ela encontra, explica e corrige com um "ok" seu.
- **Está, mas você usa o Claude pelo navegador** — funciona pela metade. Você roda a verificação
  (é um comando só) e cola o resultado no chat: o Claude explica o que apareceu e o que fazer. O
  que ele não consegue dali é corrigir sozinho; as mudanças ficam com você.
- **Não está** — você mexe no projeto direto pelo navegador e não tem cópia no computador: não é
  pra você hoje. Sem a pasta aqui, não existe o que verificar. Se um dia baixar uma cópia pro
  computador, volta a valer.

**Não importa onde o seu site ou painel está publicado na internet.** O que importa é ter a pasta
do projeto na máquina.

Ter a pasta no seu computador não é problema de segurança — é como se trabalha normalmente. O que
importa é o que está dentro dela, e é isso que a verificação olha: inclusive se a pasta está numa
que sincroniza sozinha com a nuvem, o que faz tudo dali subir junto.

No Windows, é preciso ter o Git for Windows instalado. Se faltar, o assistente avisa e ajuda.

## Em que se baseia

Nenhuma checagem foi inventada. Cada item corresponde a uma prática documentada em fonte reconhecida
pela comunidade de segurança e de desenvolvimento: OWASP (Top 10 e Secrets Management Cheat Sheet),
NIST (SP 800-53 e SP 800-63B), CIS Controls v8, orientações oficiais do GitHub, Twelve-Factor App,
e o princípio de minimização de dados da LGPD e do GDPR. A tabela com a fonte de cada checagem está
em `bases.md`, na pasta da skill. O script é uma implementação simplificada
dessas práticas pra quem não programa; não é certificação nem cobertura completa dos padrões.

## O que ela faz

Roda um script de leitura (`verificar.sh`) que confere se há senha ou chave escrita no código ou
guardada no histórico do git, se arquivo de credencial está rastreado ou fora do `.gitignore`, se as
dependências têm versão fixada, se existe proteção de commit, se sobrou cópia de backup de credencial na pasta (o arquivo que sobrevive a uma troca de chave), se há arquivo de dado (csv, xlsx, pdf)
rastreado que possa conter dado de cliente, se algum arquivo de credencial está legível por outro usuário da máquina (Mac e Linux), e se o arquivo que controla login e acesso mudou por
fora desde a última vez (comparação contra uma referência guardada só em hash, nunca em texto).
Depois pergunta o que só você sabe: repositório privado, verificação em duas etapas nas contas,
quem abre o app publicado, planilha compartilhada com "qualquer pessoa com o link", acesso de quem
saiu, troca de chave.

Cada item termina em um de três estados: verificado e correto, verificado com problema, ou fora do
alcance do agente. Nunca "está tudo OK". Comando que falha vira "erro", não "correto".

## O que ela não faz

- Não altera nenhum arquivo do seu projeto sem sua confirmação na tela, e cada alteração é
  proposta uma a uma, com o motivo. As que ela pode propor: os dois arquivos dela dentro de
  `.seguranca-verificar/` na raiz do projeto; linhas no `.gitignore`; tirar um arquivo de
  credencial ou de dado do versionamento (ele continua na sua pasta); tirar uma chave de dentro
  de um arquivo e fazer o código ler do cofre da plataforma; uma proteção mínima de commit (um
  arquivo na pasta do git, removível a qualquer momento); a lista de aprovação manual do
  assistente; mover o `.env` e arquivos de dado pra fora de pasta sincronizada na nuvem; uma
  linha de lembrete no arquivo de instruções do projeto; apagar cópia de backup de credencial depois que você confirmar que a chave antiga foi revogada; ajustar a permissão de arquivo de credencial no Mac e Linux; e um commit local no fim.
- Não mostra o valor de senha ou chave, nem copia pra lugar nenhum.
- Não faz push e não troca credencial por você. Só reescreve histórico do git num caso, com sua
  confirmação: repositório que nunca foi enviado pra lugar nenhum, com cópia de segurança antes e
  depois da troca da credencial exposta.
- Não executa o código do projeto. Na internet, só faz o `git fetch` do seu próprio repositório
  (sem pedir senha) e, quando não conhece a plataforma que você usa, consulta a documentação
  oficial dela pra não te perguntar o que dá pra descobrir.
- Não depende de nenhuma outra skill: funciona instalada sozinha.
- Não garante proteção contra golpe direcionado, falha da plataforma ou invasão da sua conta por
  fora do projeto. Detector de segredo funciona por formato conhecido: senha simples em variável
  de nome inocente passa.

## O que ela faz de diferente

Achar segredo em código é a parte fácil, e existe ferramenta melhor que esta pra isso — quem
programa deve usá-la. O problema que esta skill resolve é o outro: **o que fazer depois que o
alerta aparece.** É aí que quem não programa trava, e é onde ela concentra o trabalho:

- **Nenhum item termina em "está tudo OK".** Cada um sai em um de três estados — verificado e
  correto, verificado e com problema, ou fora do alcance do agente — sempre com a evidência do
  que foi olhado. Comando que falha vira "não foi possível verificar", nunca "correto". Isso é o
  que permite conferir o resultado em vez de acreditar nele.
- **A ordem certa vem junto.** Segredo exposto não se resolve apagando a linha: primeiro trocar a
  chave, depois tirar do arquivo, o histórico por último. A skill conduz nessa ordem e explica por
  que ela não pode ser invertida.
- **A correção é executada, não recomendada.** O que dá pra corrigir daqui é feito na hora, em
  primeira pessoa, com o motivo e um "ok" seu — não vira lição de casa sua.
- **Ela cobre o que só você sabe.** Repositório privado, verificação em duas etapas, quem abre o
  app publicado, planilha aberta por link, acesso de quem saiu da equipe: nada disso está no
  código, e ficar de fora do relatório é justamente o que dá a falsa sensação de estar protegido.
- **Guarda estado entre execuções** e sabe o que mudou desde a última vez, inclusive se o arquivo
  que controla o login foi alterado por fora.

## Por que não só pedir pro Claude "revisar a segurança"?

Você pode, e vai receber alguma coisa útil. A diferença está em três pontos:

- **A lista é sempre a mesma.** Pedindo solto, cada vez vem uma resposta diferente e você não tem
  como saber o que ficou de fora. Aqui os itens são fixos, e cada um vem com a evidência do que
  foi olhado.
- **Nunca termina em "está tudo OK".** Item que não deu pra verificar sai como "fora do alcance",
  não como "correto". É isso que te deixa conferir em vez de acreditar.
- **Ela lembra da última vez.** Guarda o que já foi verificado e avisa, por exemplo, se o arquivo
  que controla o login mudou desde então. Um pedido solto começa do zero toda vez.

Se você já sabe o que perguntar e o que fazer com a resposta, provavelmente não precisa disto.
Foi feita pra quem não sabe.

## Relação com a `/security-review` nativa do Claude Code

O Claude Code tem um comando próprio, `/security-review`, que faz uma revisão de segurança do
**código alterado na branch atual**: procura vulnerabilidade no que está sendo programado
(validação de entrada, injeção, uso inseguro de biblioteca), fala em termos de desenvolvedor e
termina quando entrega o parecer. Esta skill faz outra coisa: cuida da **higiene de segurança do
projeto** pra quem não programa (segredo em arquivo e no histórico inteiro, `.gitignore`, proteção
de commit, dado de cliente no git, login adulterado, modo de permissão do assistente, contas e
compartilhamentos), guarda estado entre execuções e conduz a pessoa do início ao fim. As duas se
complementam: se o seu projeto tem código de verdade e você usa o Claude Code, ao final desta
verificação o assistente sugere rodar a nativa também.

## Arquivos

- `SKILL.md`: a instrução que o assistente segue (formato aberto Agent Skills, com uma tabela de portabilidade pra outras ferramentas).
- `textos.md`: o que o assistente diz à pessoa em cada momento (abertura, cada item, perguntas de conta, encerramento), separado das regras pra o `SKILL.md` ficar curto.
- `bases.md`: a fonte de cada checagem (OWASP, NIST, CIS, GitHub, LGPD).
- `verificar.sh`: o script de leitura. Roda no Git Bash (que o Claude Code usa no Windows) e em
  qualquer shell de Mac ou Linux. Pode ser lido inteiro antes de usar; não tem nada escondido.

## Contexto de origem

Criada em setembro de 2026 pra operação de um gestor de tráfego pago, com um painel de clientes
publicado e credenciais em `.env` e no painel de Secrets da hospedagem. Testada em Windows 11 com
Claude Code pelo VS Code, num projeto de teste com erros colocados de propósito (segredo em código
e no histórico, `.gitignore` vazio, dependência sem versão, arquivo de acesso adulterado, pasta sem
git). Em setembro de 2026 foi rodada também em macOS (15.3.1, bash 3.2, grep BSD) num projeto de
terceiro com 458 arquivos versionados, sem erro de compatibilidade; o retorno dessa execução virou
correção de precisão dos padrões de detecção na v0.3.3. Linux ainda não foi testado. Precisa de `bash`
(no Windows, vem com o Git for Windows). Passou por várias rodadas de teste humano (a pessoa
rodando a skill como usuária, do início ao fim, com cada achado virando correção) e por sete
rodadas de validação sintética (dois cenários fictícios, um deles simulando o Cursor; comparação
cega entre versões e crítica independente por um agente na persona de consultor de segurança),
com mais de 40 correções aplicadas a partir delas. A simulação do Cursor é isso, simulação: a
skill não foi rodada de verdade fora do Claude Code.

Adapte à sua realidade. Uso por sua conta e risco (ver README principal do repositório).
