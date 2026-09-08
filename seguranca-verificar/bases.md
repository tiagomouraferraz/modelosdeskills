# Em que cada checagem da skill seguranca-verificar se baseia

Fontes reconhecidas pela comunidade de segurança e de desenvolvimento. O script implementa cada
prática de forma simplificada, pro contexto de quem não programa; não substitui os padrões nem
certifica conformidade com eles. Quando a pessoa pedir as bases, mostrar esta tabela em linguagem
simples, item por item, sem inflar.

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
| Controle de acesso do arquivo de login (autenticar antes, mostrar só o que é da pessoa) | OWASP Top 10 (A01, controle de acesso quebrado); princípio de menor privilégio, NIST SP 800-53, controle AC-6 |
| 2 Verificação em duas etapas | NIST SP 800-63B (autenticação; preferir método resistente a phishing) e orientação da CISA pra pequenas empresas |
| 2 Repositório privado, app com acesso restrito, planilha não pública | Menor privilégio e controle de acesso: NIST SP 800-53, controles AC-3 e AC-6; CIS Controls v8, controles 3 e 6 |
| 2 Acesso de quem saiu removido | Gestão de contas: NIST SP 800-53, controle AC-2; CIS Controls v8, controle 5 |
| 2 Rotação de chave a cada ~90 dias | Recomendação da documentação do Google Cloud pra chave de conta de serviço; prática geral de rotação de credencial (OWASP Secrets Management) |
| 2 Disco criptografado | CIS Controls v8, controle 3.6 (criptografia em dispositivo de usuário final); orientação da CISA |
| 1.10 Modo de permissão do assistente (nunca o que executa sem confirmar; conector de escrita em aprovação manual) | Menor privilégio aplicado ao próprio agente: NIST SP 800-53, controle AC-6; documentação oficial da Anthropic sobre modos de permissão e `permissions.ask`/`deny` do Claude Code; OWASP Top 10 for LLM Applications, edição 2023 (LLM01, injeção de prompt; LLM08, autonomia excessiva — a numeração mudou em edições posteriores da lista) |
| Três estados, nunca "está tudo OK" | Princípio de auditoria com evidência: NIST SP 800-53A (avaliação por exame, entrevista e teste; sem evidência, não há conformidade) |
