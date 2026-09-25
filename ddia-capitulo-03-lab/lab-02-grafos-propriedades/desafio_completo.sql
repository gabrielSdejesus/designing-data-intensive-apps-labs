create table locais (
	id int primary key,
	nome text,
	fk_parent_id int,
	constraint fk_parent_id foreign key (fk_parent_id) references locais (id)
);

create table pessoas (
	id int primary key,
	nome text,
	fk_cidade_id int,
	constraint fk_cidade_id  foreign key (fk_cidade_id) references locais (id)
);

insert into locais (id, nome, fk_parent_id) 
values (1, 'brasil', null);

insert into locais (id, nome, fk_parent_id) 
values 
  (2, 'são paulo', 1),
  (3, 'rio de janeiro', 1);

insert into locais (id, nome, fk_parent_id) 
values 
  (4, 'campinas', 2),
  (5, 'niterói', 3);

INSERT INTO pessoas (id, nome, fk_cidade_id) 
VALUES 
  (1, 'Gabriel Silva', 4),
  (2, 'Bruno Costa', 5);

SELECT 
  p.nome AS pessoa,
  cidade.nome AS cidade,
  estado.nome AS estado,
  pais.nome AS pais
FROM pessoas p
INNER JOIN locais cidade ON p.fk_cidade_id = cidade.id
INNER JOIN locais estado ON cidade.fk_parent_id = estado.id
INNER JOIN locais pais   ON estado.fk_parent_id = pais.id;

commit;

-- Chamada recursiva dos municípios de acordo com o id da pessoa DOC referencial https://www.postgresql.org/docs/9.1/queries-with.html
with recursive recursividade as (
	select p.id as id_pessoa, 
		   p.nome as nome_pessoa,
		   l.id as id_cidade,
		   l.fk_parent_id as proximo_id, 
		   l.nome  as nome_local
    from pessoas p join locais l on p.fk_cidade_id = l.id
	
	union all
	
	select r.id_pessoa, 
	       r.nome_pessoa, 
	       l.id as id_cidade,
	       l.fk_parent_id as proximo_id, 
	       l.nome as nome_local
	 from recursividade r join locais l on r.proximo_id = l.id
)

-- Trazendo informação de qual país Gabriel nasceu/mora
select * from recursividade where nome_pessoa = 'Gabriel Silva' and proximo_id is null;