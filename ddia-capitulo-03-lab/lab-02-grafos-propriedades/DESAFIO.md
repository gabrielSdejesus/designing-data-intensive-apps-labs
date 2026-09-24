## Lab 2: Grafos de Propriedades vs SQL Recursivo

* **Bancos utilizados:** Neo4j (Cypher) e PostgreSQL (SQL puro)
* **Conceitos:** Relações N:N complexas, fechamento transitivo (*transitive closure*) e travessia de grafos com profundidade dinâmica.

### Cenário de Negócio
Você precisa modelar uma hierarquia geográfica encadeada:
$$\text{Cidade} \longrightarrow \text{Estado} \longrightarrow \text{Região} \longrightarrow \text{País}$$


Além disso, pessoas nascem em cidades e mantêm conexões de amizade entre si.

### Desafios Práticos

1. **Desafio no Neo4j (Cypher):**
   * Acesse [http://localhost:7474](http://localhost:7474).
   * Crie nós para representar entidades: `:Person` (com nome) e `:Location` (com nome e tipo, como Cidade, Estado, Região e País).
   * Conecte a hierarquia geográfica inteira usando arestas `[:WITHIN]`. Conecte pessoas às suas cidades de nascimento com `[:BORN_IN]` e pessoas a pessoas com `[:FRIENDS_WITH]`.
   * **A Consulta Desafio:** Escreva uma query em Cypher que responda: *"Quais amigos de 'Gabriel' nasceram no 'Brasil'?"*. A query não pode fixar a quantidade de saltos entre a cidade e o país (deve usar travessia de caminho com profundidade variável `*`).

2. **Desafio no PostgreSQL (SQL Recursivo):**
   * No Postgres, crie uma tabela auto-relacionada para representar a mesma hierarquia geográfica: `locais (id, nome, parent_id)`.
   * Crie a tabela `pessoas (id, nome, cidade_id)`.
   * **A Consulta Desafio:** Tente responder à mesma pergunta (*"Gabriel nasceu no Brasil?"*) escrevendo uma Common Table Expression recursiva (`WITH RECURSIVE`).

> 💡 **Ponto de Reflexão para o seu README:**  
> Compare o tamanho e a complexidade cognitiva da query Cypher contra o `WITH RECURSIVE` em SQL. Por que o livro defende que modelos de grafos de propriedades são muito mais adequados quando o número de saltos em uma relação é indefinido?