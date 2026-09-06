# seguranca-verificar

Skill de verificação de segurança pra projeto de Claude Code de quem não programa.

## Como instalar

1. Baixe o zip na aba Releases do repositório.
2. Descompacte dentro de `~/.claude/skills/` (Windows: `C:\Users\SEU-USUARIO\.claude\skills\`).
   A pasta `seguranca-verificar` já vem com o nome certo. Se a pasta `skills` não existir, crie com esse nome. No Windows, ao usar "Extrair tudo", apague o final do caminho de destino (o nome do zip) pra não ficar `seguranca-verificarseguranca-verificar`. O resultado certo é `skillsseguranca-verificarSKILL.md`.
3. Abra o Claude Code na pasta do seu projeto e chame `/seguranca-verificar`. Na primeira vez ela
   confirma a pasta, faz cinco perguntas em linguagem simples, e você pode autorizar que ela olhe a
   pasta e responda sozinha, só pra você confirmar.

## O que ela faz

Roda um script de leitura (`verificar.sh`) que confere se há senha ou chave escrita no código ou
guardada no histórico do git, se arquivo de credencial está rastreado ou fora do `.gitignore`, se as
dependências têm versão fixada, se existe proteção de commit, se há arquivo de dado (csv, xlsx, pdf)
rastreado que possa conter dado de cliente, e se o arquivo que controla login e acesso mudou por
fora desde a última vez (comparação contra uma referência guardada só em hash, nunca em texto).
Depois pergunta o que só você sabe: repositório privado, verificação em duas etapas nas contas,
quem abre o app publicado, planilha compartilhada com "qualquer pessoa com o link", acesso de quem
saiu, troca de chave.

Cada item termina em um de três estados: verificado e correto, verificado com problema, ou fora do
alcance do agente. Nunca "está tudo OK". Comando que falha vira "erro", não "correto".

## O que ela não faz

- Não altera nenhum arquivo do seu projeto, exceto os dois dela dentro de `.claude/` e, com sua
  confirmação na tela, linhas no `.gitignore`.
- Não mostra o valor de senha ou chave, nem copia pra lugar nenhum.
- Não reescreve histórico do git, não faz push, não troca credencial por você.
- Não instala nada, não executa o código do projeto, não acessa a internet além do `git fetch` do
  seu próprio repositório (sem pedir senha).
- Não garante proteção contra golpe direcionado, falha da plataforma ou invasão da sua conta por
  fora do projeto. Detector de segredo funciona por formato conhecido: senha simples em variável
  de nome inocente passa.

## Arquivos

- `SKILL.md`: a instrução que o Claude Code segue.
- `verificar.sh`: o script de leitura. Roda no Git Bash (que o Claude Code usa no Windows) e em
  qualquer shell de Mac ou Linux. Pode ser lido inteiro antes de usar; não tem nada escondido.

## Contexto de origem

Criada em setembro de 2026 pra operação de um gestor de tráfego pago, com um painel de clientes
publicado e credenciais em `.env` e no painel de Secrets da hospedagem. Testada em Windows 11 com
Claude Code pelo VS Code, num projeto de teste com erros colocados de propósito (segredo em código
e no histórico, `.gitignore` vazio, dependência sem versão, arquivo de acesso adulterado, pasta sem
git). Não testada em Mac ou Linux, embora os comandos sejam padrão de shell. Passou por uma rodada
de crítica independente antes de publicar.

Adapte à sua realidade. Uso por sua conta e risco (ver README principal do repositório).
