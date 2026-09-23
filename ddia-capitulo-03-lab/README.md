# Infraestrutura Única: `docker-compose.yml`

Coloque este arquivo na raiz do seu repositório de estudos. Ele provisiona os dois motores necessários para cobrir todos os 4 laboratórios:

- **PostgreSQL 16**: Atende aos Labs 1 (*Relacional vs JSONB*), 3 (*Star Schema OLAP*) e 4 (*Log de Eventos e Projeções CQRS*).
- **Neo4j 5**: Atende ao Lab 2 (*Grafos de Propriedades e Cypher*).

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: ddia-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgrespassword
      POSTGRES_DB: ddia_lab
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  neo4j:
    image: neo4j:5-community
    container_name: ddia-neo4j
    restart: unless-stopped
    environment:
      NEO4J_AUTH: neo4j/ddiapassword
    ports:
      - "7474:7474" # Interface Web (Neo4j Browser)
      - "7687:7687" # Protocolo Bolt (drivers e conexões)
    volumes:
      - neo4jdata:/data

volumes:
  pgdata:
  neo4jdata:
```

---

## Como subir e testar os acessos

* **Subir tudo:**
  ```bash
  docker compose up -d
  ```
* **Acessar o Postgres:**
  * **Parâmetros:** `Host: localhost:5432` | `Banco: ddia_lab` | `Usuário: postgres` | `Senha: postgrespassword`
  * **Via terminal:**
    ```bash
    docker exec -it ddia-postgres psql -U postgres -d ddia_lab
    ```
* **Acessar o Neo4j:**
  * **Interface Web:** [http://localhost:7474](http://localhost:7474)
  * **Credenciais:** `Usuário: neo4j` | `Senha: ddiapassword`

---

## Estrutura de Pastas do Repositório

```plaintext
ddia-capitulo-03-lab/
├── docker-compose.yml
├── README.md
├── lab-01-relacional-vs-documentos/
│   ├── DESAFIO.md
│   └── solucao.sql
├── lab-02-grafos-propriedades/
│   ├── DESAFIO.md
│   ├── solucao.cypher
│   └── solucao-recursiva.sql
├── lab-03-modelagem-dimensional-olap/
│   ├── DESAFIO.md
│   └── solucao.sql
└── lab-04-cqrs-e-event-sourcing/
    ├── DESAFIO.md
    └── solucao.sql
```

---

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

---

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

---

## Lab 3: Modelagem Dimensional para Análise (Star Schema / OLAP)

* **Banco utilizado:** PostgreSQL (`ddia_lab`)
* **Conceitos:** Transacional (OLTP) vs Analítico (OLAP), esquemas estrela vs floco de neve, tabelas de fatos e tabelas de dimensões.

### Cenário de Negócio
A diretoria de uma rede varejista quer um Data Warehouse para analisar vendas consolidadas cruzando três eixos: tempo, produto e loja.

### Desafios Práticos

1. **Construção do Star Schema:**
   * Crie as tabelas de dimensões desnormalizadas:
     * `dim_tempo` (chave substituta, data completa, mês, ano, trimestre).
     * `dim_produto` (chave substituta, nome, categoria, marca).
     * `dim_loja` (chave substituta, nome_loja, cidade, estado).
   * Crie a tabela de fatos central:
     * `fato_vendas` (chaves estrangeiras para as dimensões + métricas numéricas: quantidade vendida, valor unitário, valor total).
   * Insira uma massa de testes com vendas espalhadas por diferentes datas, categorias e estados.

2. **Consulta Analítica OLAP:**
   * Escreva uma consulta que realize operações analíticas típicas (*slice and dice*): agrupar o faturamento total e quantidade de itens vendidos por ano, estado e categoria de produto.

> 💡 **Ponto de Reflexão para o seu README:**  
> Por que no banco transacional (OLTP) normalizamos tudo para evitar inconsistência de escrita, mas no Star Schema (OLAP) deixamos as tabelas de dimensão intencionalmente desnormalizadas (largas)?

---

## Lab 4: CQRS e Projeções Derivadas de um Log de Eventos

* **Banco utilizado:** PostgreSQL (`ddia_lab`)
* **Conceitos:** Separação de modelos de escrita e leitura (CQRS), Event Sourcing como fonte primária imutável, e views materializadas como projeções de consulta.

### Cenário de Negócio
Você foi encarregado de implementar um sistema de pedidos onde não existe UPDATE de estado. Qualquer ação do usuário é tratada como um evento imutável gravado em um log de eventos (*Event Store*). A interface do cliente, no entanto, precisa consultar o saldo consolidado do pedido em milissegundos sem precisar recalcular a lista histórica de eventos em tempo de leitura.

### Desafios Práticos

1. **Modelo de Escrita Primário (Append-Only Log):**
   * Crie uma tabela `pedidos_eventos` que aceite estritamente `INSERT`. Ela deve conter colunas para: `id` (sequencial), `pedido_id`, `tipo_evento` (ex: `PEDIDO_CRIADO`, `ITEM_ADICIONADO`, `DESCONTO_APLICADO`, `PAGAMENTO_CONFIRMADO`, `PEDIDO_CANCELADO`), `dados_evento` (JSONB) e `criado_em` (TIMESTAMP).
   * Insira uma sequência realista de eventos para 2 pedidos diferentes demonstrando a evolução de seus estados.

2. **Modelo de Leitura Otimizado (Projeção CQRS):**
   * Crie uma tabela ou `MATERIALIZED VIEW` chamada `pedidos_resumo_leitura` contendo os campos prontos para renderizar na tela: `pedido_id`, `quantidade_itens`, `valor_total`, `status_final`, `ultima_atualizacao`.
   * Escreva a consulta agregadora que varre os eventos brutos de `pedidos_eventos`, interpreta a sequência cronológica das mudanças e preenche a projeção de leitura.

3. **Simulação do Ciclo Completo:**
   * Simule uma nova ação no sistema inserindo um evento de cancelamento (`PEDIDO_CANCELADO`) para um dos pedidos no log.
   * Execute a atualização da projeção (se usou `MATERIALIZED VIEW`, use `REFRESH MATERIALIZED VIEW`).
   * Faça a consulta de leitura da tela (`SELECT * FROM pedidos_resumo_leitura WHERE pedido_id = X`) e comprove que o dado vem desnormalizado, pré-calculado e pronto em uma única operação de chave-valor.

> 💡 **Ponto de Reflexão para o seu README:**  
> De que forma essa arquitetura atende à definição exata de CQRS: *"uma representação separada, otimizada para leitura e derivada de uma representação otimizada para gravação"*?

---

*Com esse r