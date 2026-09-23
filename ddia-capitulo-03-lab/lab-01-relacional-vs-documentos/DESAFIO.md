# Os 4 Laboratórios de Desafios

## Lab 1: Relacional vs Documentos e Localidade de Armazenamento

* **Banco utilizado:** PostgreSQL (`ddia_lab`)
* **Conceitos:** Incompatibilidade objeto-relacional (*impedance mismatch*), normalização vs desnormalização, localidade de dados em disco com JSONB.

### Cenário de Negócio
Você precisa desenhar o modelo de dados para o perfil de um profissional (estilo LinkedIn). Cada usuário tem nome, bio, múltiplas experiências profissionais (cada uma contendo cargo, empresa, ano início e ano fim) e formações acadêmicas.

### Desafios Práticos

1. **Modelagem 3NF (Relacional Estrito):**
   * Modele as tabelas normalizadas com chaves primárias e estrangeiras (`usuarios`, `experiencias_profissionais`, `formacoes_academicas`).
   * Popule com dados de teste contendo pelo menos 1 usuário com 2 experiências e 1 formação.
   * Escreva a consulta SQL necessária para reconstruir o objeto completo do perfil desse usuário. Observe o custo de múltiplos `LEFT JOIN`s e a repetição de dados do usuário no retorno.

2. **Modelagem de Documento (Postgres JSONB):**
   * Crie uma tabela `usuarios_documento (id, perfil JSONB)`.
   * Insira a mesma estrutura de dados anterior como um documento JSON completo.
   * Escreva uma consulta que traga o perfil completo em uma única busca direta por ID (sem nenhum `JOIN`), aproveitando a localidade de armazenamento.
   * Escreva uma consulta que filtre documentos onde o usuário trabalhou em uma empresa específica utilizando operadores nativos de JSON do Postgres (ex: `@>` ou `jsonb_path_query`).

> 💡 **Ponto de Reflexão para o seu README:**  
> Se uma empresa alterar seu nome institucional, qual é o impacto em cada um dos dois modelos? Relacione sua resposta com o *trade-off* entre localidade de leitura e custo de atualização desnormalizada.