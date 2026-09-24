create table usuarios (
	id int primary key,
	nome varchar (255),
	bio varchar (500)
);

create table experiencias_profissionais (
	id int primary key,
	fk_experiencias_usuario int,
	cargo varchar(255),
	empresa varchar(255),
	ano_inicio numeric (4),
	ano_fim numeric (4),
	constraint fk_experiencias_usuario foreign key (fk_experiencias_usuario) references usuarios (id)
);

create table formacoes_academicas (
	id int primary key,
	fk_formacoes_usuario int,
	nome_escola varchar(255),
	ano_inicio numeric (4),
	ano_fim numeric (4),
	completo boolean,
	constraint fk_formacoes_usuario foreign key (fk_formacoes_usuario) references usuarios(id)
);

select * from usuarios;
select * from experiencias_profissionais;
select * from formacoes_academicas;

-- Alguns desses dados foram gerados via AI afim de reduzir a redundância do trabalho
insert into usuarios (id, nome, bio) 
values ((select coalesce(max(id), 0) + 1 from usuarios), 'Gabriel', 'Sou um desenvolvedor fullstack com 4 anos de experiência.');

insert into usuarios (id, nome, bio) 
values ((select coalesce(max(id), 0) + 1 from usuarios), 'Jorge', 'Pronto para arquitetar sistemas de alta complexidade.');

insert into experiencias_profissionais (id, fk_experiencias_usuario, cargo, empresa, ano_inicio, ano_fim)
values (1, 1, 'desenvolvedor júnior', 'tech solutions', 2021, 2023);

insert into experiencias_profissionais (id, fk_experiencias_usuario, cargo, empresa, ano_inicio, ano_fim)
values (2, 1, 'desenvolvedor pleno', 'inovação digital', 2023, null);

insert into experiencias_profissionais (id, fk_experiencias_usuario, cargo, empresa, ano_inicio, ano_fim)
values (3, 2, 'analista de suporte', 'global service', 2019, 2021);

insert into experiencias_profissionais (id, fk_experiencias_usuario, cargo, empresa, ano_inicio, ano_fim)
values (4, 2, 'engenheiro de dados', 'data corp', 2021, 2025);

insert into formacoes_academicas (id, fk_formacoes_usuario, nome_escola, ano_inicio, ano_fim, completo)
values (1, 1, 'universidade federal', 2017, 2021, true);

insert into formacoes_academicas (id, fk_formacoes_usuario, nome_escola, ano_inicio, ano_fim, completo)
values (2, 1, 'instituto tecnológico', 2022, 2024, true);

insert into formacoes_academicas (id, fk_formacoes_usuario, nome_escola, ano_inicio, ano_fim, completo)
values (3, 2, 'faculdade integrada', 2018, 2022, true);

insert into formacoes_academicas (id, fk_formacoes_usuario, nome_escola, ano_inicio, ano_fim, completo)
values (4, 2, 'pós-graduação tech', 2023, null, false);


commit;

-- Aqui está a resposta dos joins para achar o resultado dos usuários (desconsiderando a busca individual)
select u.id, u.nome, u.bio, ep.cargo, fa.nome_escola, fa.ano_inicio, fa.ano_fim, fa.completo from usuarios u 
left join experiencias_profissionais ep on u.id = ep.fk_experiencias_usuario
left join formacoes_academicas fa on u.id = fa.fk_formacoes_usuario;


-- Aqui está a criação de uma tabela com jsonb afim de armazenar as propriedades em uma única coluna
create table usuarios_documento (
	id int primary key,
	perfil jsonb
);

select * from usuarios_documento;

insert into usuarios_documento (id, perfil)
values (
    1,
    '{
        "experiencias_profissionais": [
            {
                "id": 1,
                "cargo": "desenvolvedor júnior",
                "empresa": "tech solutions",
                "ano_inicio": 2021,
                "ano_fim": 2023
            },
            {
                "id": 2,
                "cargo": "desenvolvedor pleno",
                "empresa": "inovação digital",
                "ano_inicio": 2023,
                "ano_fim": null
            }
        ],
        "formacoes_academicas": [
            {
                "id": 1,
                "nome_escola": "universidade federal",
                "ano_inicio": 2017,
                "ano_fim": 2021,
                "completo": true
            },
            {
                "id": 2,
                "nome_escola": "instituto tecnológico",
                "ano_inicio": 2022,
                "ano_fim": 2024,
                "completo": true
            }
        ]
    }'::jsonb
);

insert into usuarios_documento (id, perfil)
values (
    2,
    '{
        "experiencias_profissionais": [
            {
                "id": 3,
                "cargo": "analista de suporte",
                "empresa": "global service",
                "ano_inicio": 2019,
                "ano_fim": 2021
            },
            {
                "id": 4,
                "cargo": "engenheiro de dados",
                "empresa": "data corp",
                "ano_inicio": 2021,
                "ano_fim": 2025
            }
        ],
        "formacoes_academicas": [
            {
                "id": 3,
                "nome_escola": "faculdade integrada",
                "ano_inicio": 2018,
                "ano_fim": 2022,
                "completo": true
            },
            {
                "id": 4,
                "nome_escola": "pós-graduação tech",
                "ano_inicio": 2023,
                "ano_fim": null,
                "completo": false
            }
        ]
    }'::jsonb
);

commit;

-- Este traz o perfil completo do usuário 1
select * from usuarios_documento where id = 1;

-- Este traz o perfil apenas com empresa 'tech solutions' ou 'data corp'
select * from usuarios_documento, 
-- optei por definir um alias para as experiências
lateral jsonb_array_elements(perfil->'experiencias_profissionais') as exp
where exp->> 'empresa' in ('tech solutions', 'data corp');