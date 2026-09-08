# seguranca-verificar

Verificação de segurança pra quem montou um projeto com assistente de IA e não programa: senha ou
chave esquecida dentro do código, arquivo de cliente exposto no git, proteção de commit ausente,
arquivo de login alterado por fora. Explica cada achado em linguagem simples e corrige com um
"ok" seu.

**Você precisa da pasta do projeto no seu computador** — não importa onde o site ou painel está
publicado. Criada e testada no Claude Code; escrita pra rodar em qualquer assistente que leia
instrução e execute comandos.

## Como instalar

1. Baixe o zip na aba **Releases**.
2. Descompacte dentro de `~/.claude/skills/` (Windows: `C:\Users\SEU-USUARIO\.claude\skills\`).
   No Windows, ao usar "Extrair tudo", apague o final do caminho de destino — senão a pasta fica
   duplicada. O certo é `skills` > `seguranca-verificar` > `SKILL.md`.
3. Abra o assistente na pasta do seu projeto e chame `/seguranca-verificar`. Em outra ferramenta,
   peça "use a skill seguranca-verificar". Na primeira vez ela se apresenta e configura sozinha.

## O que ela faz de diferente

Achar segredo em código é a parte fácil, e existe ferramenta melhor que esta pra isso. O que ela
resolve é o outro problema: **o que fazer depois que o alerta aparece.**

- **Nenhum item termina em "está tudo OK".** Cada um sai em um de três estados — verificado e
  correto, verificado e com problema, ou fora do alcance do agente — sempre com a evidência do que
  foi olhado. Comando que falha vira "não foi possível verificar", nunca "correto".
- **A ordem certa vem junto.** Segredo exposto não se resolve apagando a linha: primeiro trocar a
  chave, depois tirar do arquivo, o histórico por último. Ela conduz nessa ordem e explica por quê.
- **A correção é executada, não recomendada.** O que dá pra corrigir daqui é feito na hora, com o
  motivo e um "ok" seu — não vira lição de casa sua.
- **Cobre o que só você sabe.** Repositório privado, verificação em duas etapas, quem abre o app
  publicado, planilha aberta por link, acesso de quem saiu da equipe: nada disso está no código.
- **Guarda estado entre execuções** e sabe o que mudou desde a última vez, inclusive se o arquivo
  que controla o login foi alterado por fora.

## Em que se baseia

Nenhuma checagem foi inventada. Cada item corresponde a uma prática documentada em fonte
reconhecida: OWASP (Top 10 e Secrets Management Cheat Sheet), NIST (SP 800-53 e SP 800-63B), CIS
Controls v8, orientações oficiais do GitHub, Twelve-Factor App, e o princípio de minimização de
dados da LGPD e do GDPR. A fonte de cada checagem está em `bases.md`. O script é uma implementação
simplificada dessas práticas pra quem não programa; não é certificação.

## Arquivos

- `SKILL.md`: a instrução que o assistente segue (formato aberto Agent Skills, com tabela de
  portabilidade pra outras ferramentas).
- `textos.md`: o que o assistente diz em cada momento, separado das regras.
- `bases.md`: a fonte de cada checagem.
- `verificar.sh`: o script de leitura. Roda no Git Bash (que o Claude Code usa no Windows) e em
  qualquer shell de Mac ou Linux. Pode ser lido inteiro antes de usar.

## Contexto de origem

Criada em setembro de 2026 pra operação real de um gestor de tráfego pago, com painel de clientes
publicado e credenciais no `.env` e no painel da hospedagem.

Testada em Windows 11 com Claude Code, num projeto com erros colocados de propósito, e em macOS
(bash 3.2, grep BSD) num projeto de terceiro com 458 arquivos — cujo retorno virou a correção de
precisão da v0.3.3. Linux ainda não foi testado. Precisa de `bash` (no Windows, vem junto com o
Git for Windows).

Passou por rodadas de teste com pessoas usando de verdade e por sete rodadas de validação com
cenários fictícios e crítica independente, com mais de 40 correções aplicadas. Fora do Claude
Code, só foi simulada.
