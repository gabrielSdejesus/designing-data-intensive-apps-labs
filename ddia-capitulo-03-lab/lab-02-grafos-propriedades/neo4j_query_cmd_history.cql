// Criando os Locais (com a hierarquia geográfica)
CREATE (:Location { name: "Brasil", tipo: "País" });
CREATE (:Location { name: "Rio Grande do Sul", tipo: "Estado" });
CREATE (:Location { name: "Porto Alegre", tipo: "Cidade" });
CREATE (:Location { name: "Rio Grande do Norte", tipo: "Estado" });
CREATE (:Location { name: "Natal", tipo: "Cidade" });

// Criando as Pessoas
CREATE (:Person { name: "Gabriel" });
CREATE (:Person { name: "Giay" });
CREATE (:Person { name: "Neto" });
CREATE (:Person { name: "Jorge" });

// Conectando Porto Alegre -> RS -> Brasil
MATCH (l1:Location { name: "Brasil" })
MATCH (l2:Location { name: "Rio Grande do Sul" })
MATCH (l3:Location { name: "Porto Alegre" })
CREATE (l3)-[:WHITIN]->(l2)-[:WHITIN]->(l1);

// Conectando Natal -> RN -> Brasil
MATCH (l1:Location { name: "Brasil" })
MATCH (l2:Location { name: "Rio Grande do Norte" })
MATCH (l3:Location { name: "Natal" })
CREATE (l3)-[:WHITIN]->(l2)-[:WHITIN]->(l1);

// Ligando nascimento das pessoas
MATCH (p:Person { name: "Gabriel" }), (l:Location { name: "Natal" })
CREATE (p)-[:BORN_IN]->(l);

MATCH (p:Person { name: "Giay" }), (l:Location { name: "Porto Alegre" })
CREATE (p)-[:BORN_IN]->(l);

MATCH (p:Person { name: "Neto" }), (l:Location { name: "Porto Alegre" })
CREATE (p)-[:BORN_IN]->(l);

// Ligando as amizades até Gabriel
MATCH (p1:Person { name: "Giay" })
MATCH (p2:Person { name: "Neto" })
MATCH (p3:Person { name: "Jorge" })
MATCH (p4:Person { name: "Gabriel" })
CREATE (p1)-[:FRIENDS_WITH]->(p4),
       (p2)-[:FRIENDS_WITH]->(p4),
       (p3)-[:FRIENDS_WITH]->(p4);
	   
MATCH (p:Person)-[:FRIENDS_WITH]-(p1:Person { name: "Gabriel" })
MATCH (p)-[:BORN_IN]-(y:Location)-[:WHITIN*]-(z:Location { name: "Brasil" })
RETURN p.name;