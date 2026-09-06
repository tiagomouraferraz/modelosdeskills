# Tiago Moura - modelosdeskills

Skills de sistema pra Claude Code criadas por um Gestor de Tráfego Pago desde 2015 que não programa, pra operação própria.

## Como instalar

1. Baixe o zip da skill na aba **Releases**.
2. Descompacte dentro da pasta de skills do seu Claude Code. O zip já vem com a pasta no nome certo. **No Windows, ao usar "Extrair tudo", apague o final do caminho de destino** (o nome do zip que o Windows acrescenta) pra extrair direto em `skills`; senão a pasta fica duplicada (`skills
ome-da-skill
ome-da-skill`). O resultado certo é `skills
ome-da-skillSKILL.md`.
   - Windows: `C:\Users\SEU-USUARIO\.claude\skills\`
   - Mac ou Linux: `~/.claude/skills/`
   - A pasta `.claude` é oculta. Se não aparecer, digite o caminho direto na barra de endereço do explorador de arquivos. Se a pasta `skills` não existir dentro dela, crie com esse nome.
   - Alternativa: descompacte dentro de `.claude\skills\` de um projeto específico, e a skill só existe naquele projeto.
3. Abra o Claude Code e chame a skill pelo nome, com barra na frente (ex: `/nome-da-skill`). Na primeira chamada ela faz a configuração inicial.

## O que é isto

Sou Tiago Moura, profissional de Tráfego Pago desde 2015. Uso o Claude Code no dia a dia da minha operação e, como não programo, fui criando skills pra me proteger dos erros que poderia cometer: senha em código, arquivo errado subindo pro git, skill que parece boa e não é, entre outros. Este repositório junta versões genéricas das skills que uso no meu projeto para ajudar outros profissionais em contexto semelhante ao meu.

Não é produto. É o retrato de uma operação real, compartilhado pra ajudar colegas a melhorarem suas entregas.

## Em que contexto foram criadas e testadas

- Uma pessoa só, operando gestão de tráfego pago pra carteira enxuta de clientes.
- Windows 11, Claude Code pelo VS Code, modo de permissão Auto com lista de aprovação pra ferramenta conectada.
- Workspace em português, com arquivo de instruções (AGENTS.md), skills próprias e hooks de segurança.
- Criadas e usadas entre agosto e setembro de 2026.
- **Testadas só nesse ambiente.** Nada foi testado em Mac ou Linux. Onde uma skill tiver versão pra esses sistemas, o README dela diz se foi testada ou não.

## Limitações

- Cada skill replica a minha realidade de uso. Mesmo depois de tirar tudo que era específico do meu negócio, pode sobrar instrução que só faz sentido no meu contexto.
- Barreira de segurança aqui é guardrail de ferramenta, não proteção criptográfica. Quem tem a máquina consegue desligar. Detector funciona por formato conhecido (chave de API, token, chave privada, senha em variável com nome óbvio). Uma senha simples numa variável com nome inocente passa. É possível que existam outros furos, então isto não é uma ferramenta de segurança definitiva: a regra é segredo nunca sair do arquivo de credenciais, e o detector é a rede de proteção contra o erro, não a regra.
- Nada aqui substitui você olhar o que o agente faz antes de aprovar.
- Existem formas mais avançadas de fazer boa parte disso. O critério aqui foi "funciona pra mim e eu uso", não "é a melhor solução conhecida".

## Adapte à sua realidade

Rode, teste, ajuste e molde cada skill ao seu projeto antes de confiar nela. O que está aqui é ponto de partida, não padrão. A skill de validação de skill deste mesmo pacote serve pra isso.

## Sem suporte

Não há atendimento a pedido de ajuda, issue ou pull request. O repositório é compartilhado como está. Quem quiser evoluir, faz um fork.

## Responsabilidade

Uso por sua conta e risco. Os efeitos diretos e indiretos de instalar e executar qualquer skill deste repositório são de responsabilidade de quem instala e executa, não minha. Meu papel aqui é só compartilhar algo que está funcionando pra mim, no meu contexto. Leia cada skill antes de usar, teste primeiro num projeto sem dado importante e mantenha backup do que for seu. A licença MIT diz isso em termos legais ("sem garantia de qualquer tipo"); este parágrafo diz em português claro.

## Skills

As skills entram uma por vez, cada uma com o próprio zip na aba **Releases** e um README próprio dentro da pasta.

| Skill | O que faz | Pasta |
| --- | --- | --- |
| `/seguranca-verificar` | Verificação de segurança do projeto: segredo em código ou no histórico, credencial fora do `.gitignore`, proteção de commit, integridade do arquivo de login, e as perguntas que só você responde. Cada item em um de três estados, nunca "está tudo OK". | [seguranca-verificar](seguranca-verificar/) |

## Licença

MIT. Use, copie e adapte à vontade, inclusive comercialmente, mantendo o crédito.

Se foi útil, compartilha com um colega. Valeu!
