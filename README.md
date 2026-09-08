# Tiago Moura - modelosdeskills

Skills de sistema pra Claude Code criadas por um Gestor de Tráfego Pago desde 2015, pra operação própria.

> Última atualização: 2026-09-08 — `seguranca-verificar` v0.3.3. Cada skill é publicada e atualizada
> pela aba **Releases**; o histórico de mudanças de cada versão está na descrição da release.

## Como instalar

1. Baixe o zip da skill na aba **Releases**.
2. Descompacte dentro da pasta de skills do seu Claude Code. O zip já vem com a pasta no nome certo. **No Windows, ao usar "Extrair tudo", apague o final do caminho de destino** (o nome do zip, que o Windows acrescenta sozinho) pra extrair direto na pasta `skills`; senão a pasta fica duplicada (`skills` > `nome-da-skill` > `nome-da-skill`). O resultado certo é `skills` > `nome-da-skill` > `SKILL.md`.
   - Windows: `C:\Users\SEU-USUARIO\.claude\skills\`
   - Mac ou Linux: `~/.claude/skills/`
   - A pasta `.claude` é oculta. Se não aparecer, digite o caminho direto na barra de endereço do explorador de arquivos. Se a pasta `skills` não existir dentro dela, crie com esse nome.
   - Alternativa: descompacte dentro de `.claude\skills\` de um projeto específico, e a skill só existe naquele projeto.
3. Abra o Claude Code e chame a skill pelo nome, com barra na frente (ex: `/nome-da-skill`). Na primeira chamada ela faz a configuração inicial.

## Skills

As skills entram uma por vez, cada uma com o próprio zip na aba **Releases** e um README próprio dentro da pasta.

| Skill | O que faz | Pasta |
| --- | --- | --- |
| `/seguranca-verificar` | Assistente de segurança que varre o seu projeto (código, histórico do git, arquivos de credencial e de dado, arquivo de login, modo de permissão do próprio assistente), explica cada achado em linguagem simples e aplica as correções pra você, seguindo práticas documentadas por OWASP, NIST, CIS Controls, GitHub e LGPD. | [seguranca-verificar](seguranca-verificar/) |

## O que é isto

Sou Tiago Moura, profissional de Tráfego Pago desde 2015. Uso o Claude Code no dia a dia da minha operação e, como não programo, fui criando skills pra me proteger dos erros que poderia cometer: senha em código, arquivo errado subindo pro git, skill que parece boa e não é, entre outros. Este repositório junta versões genéricas das skills que uso no meu projeto para ajudar outros profissionais em contexto semelhante ao meu.

Não é produto. É o retrato de uma operação real, compartilhado pra ajudar colegas a melhorarem suas entregas.

## Em que contexto foram criadas e testadas

- Uma pessoa só, operando gestão de tráfego pago pra carteira enxuta de clientes.
- Windows 11, Claude Code pelo VS Code, modo de permissão Auto com lista de aprovação pra ferramenta conectada.
- Workspace em português, com arquivo de instruções (AGENTS.md), skills próprias e hooks de segurança.
- Criadas e usadas entre agosto e setembro de 2026.
- **Testado principalmente nesse ambiente.** A `seguranca-verificar` também já rodou em macOS
  (bash 3.2, grep BSD) num projeto de terceiro, sem erro de compatibilidade. Linux ainda não foi
  testado. Onde uma skill tiver versão pra esses sistemas, o README dela diz o que foi testado.
- **Escritas pra funcionar em qualquer assistente de IA** que leia arquivo de instrução e rode shell (Claude Code, Codex, Cursor, Gemini CLI ou outro). O Claude Code aparece nos textos só como exemplo concreto, e cada skill traz uma tabela de portabilidade com o equivalente nas outras ferramentas. Só o Claude Code foi testado.

## Limitações

- Cada skill replica a minha realidade de uso. Mesmo depois de tirar tudo que era específico do meu negócio, pode sobrar instrução que só faz sentido no meu contexto.
- Barreira de segurança aqui é guardrail de ferramenta, não proteção criptográfica. Quem tem a máquina consegue desligar. Detector funciona por formato conhecido (chave de API, token, chave privada, senha em variável com nome óbvio). Uma senha simples numa variável com nome inocente passa. É possível que existam outros furos, então isto não é uma ferramenta de segurança definitiva: a regra é segredo nunca sair do arquivo de credenciais, e o detector é a rede de proteção contra o erro, não a regra.
- Nada aqui substitui você olhar o que o agente faz antes de aprovar.
- Existe ferramenta de varredura de segredo mais avançada que a daqui, e quem programa deve usá-la.
  O que estas skills fazem de diferente não é achar mais coisa: é conduzir quem não programa do
  começo ao fim — descobrir sozinha o que dá, explicar cada achado em linguagem simples, executar
  a correção com um "ok", nunca terminar em "está tudo OK", e não deixar item nenhum sem um dos
  três estados. Achar o problema é a parte fácil; saber o que fazer com ele é o que trava a maioria
  das pessoas, e é aí que estas skills atuam.

## Adapte à sua realidade

Rode, teste, ajuste e molde cada skill ao seu projeto antes de confiar nela. O que está aqui é ponto de partida, não padrão. A skill de validação de skill deste mesmo pacote serve pra isso.

## Sem suporte

Não há atendimento a pedido de ajuda nem a pull request, e não há prazo de resposta. O repositório é
compartilhado como está; quem quiser evoluir, faz um fork. **Achou um bug, ou rodou em Mac ou Linux
e algo quebrou? Abre uma issue** — retorno de quem usou de verdade é o que faz estas skills
melhorarem, e várias correções já vieram por aí.

## Responsabilidade

Uso por sua conta e risco. Os efeitos diretos e indiretos de instalar e executar qualquer skill deste repositório são de responsabilidade de quem instala e executa, não minha. Meu papel aqui é só compartilhar algo que está funcionando pra mim, no meu contexto. Leia cada skill antes de usar, teste primeiro num projeto sem dado importante e mantenha backup do que for seu. A licença MIT diz isso em termos legais ("sem garantia de qualquer tipo"); este parágrafo diz em português claro.

## Licença

MIT. Use, copie e adapte à vontade, inclusive comercialmente, mantendo o crédito.

Se foi útil, compartilha com um colega. Valeu!
