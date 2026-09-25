create table alunos(
id serial primary key,
nome varchar(150) not null,
email varchar (150) unique not null,
cpf varchar(11) unique not null, 
telefone varchar(11) not null, 
data_cadastro timestamp default current_timestamp

)

create table planos(
id serial primary key,
nome varchar(150) unique not null,
valor_mensal_base decimal(10,2) not null check (valor_mensal_base > 0)
)

create table modalidades(
id serial primary key,
plano_id int not null,
nome varchar(50) not null,
sala varchar(50) not null, 
capacidade_maxima INT NOT NULL CHECK (capacidade_maxima > 0),
disponível boolean default true,
constraint fk_modalidades_planos foreign key (plano_id) references planos(id)
)

create table matriculas(
id serial primary key,
aluno_id int not null,
data_inicio timestamp default current_timestamp,
status varchar(20) default 'ativo' check (status in ('ativa', 'cancelada', 'trancada')),
constraint fk_matriculas_alunos foreign key (aluno_id) references alunos(id)
)

create table itens_matriculas(
id serial primary key,
matricula_id int not null,
modalidade_id int not null,
duracao_meses int not null check (duracao_meses > 0),
taxa_adesao decimal(10,2) default 0.00 check (taxa_adesao >= 0),
constraint fk_matricula_matriculas foreign key(matricula_id) references matriculas(id),
constraint fk_matricula_modalidade foreign key (modalidade_id) references modalidades(id)
)

INSERT INTO planos (nome, valor_mensal_base) VALUES
('Basic Fit', 89.90),
('Fitness Standard', 120.00),
('VIP Premium', 250.00);

INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima, disponível) VALUES
(16, 'Musculação Livre', 'Arena 01', 50, TRUE),
(17, 'Crossfit Pro', 'Estúdio 01', 20, TRUE),
(18, 'Pilates Avançado', 'Estúdio 02', 10, TRUE);

INSERT INTO alunos (nome, email, cpf, telefone) VALUES
('Carlos Eduardo', 'carlos@email.com', '12345678901', '11988887777'),
('Mariana Lima', 'mariana@email.com', '98765432100', '11977776666'),
('Roberto Souza', 'roberto@email.com', '45678912300', '11966665555');

INSERT INTO matriculas (aluno_id, status) VALUES
(1, 'ativa'),
(2, 'ativa'),
(3, 'ativa'),
(1, 'cancelada');

INSERT INTO itens_matriculas (matricula_id, modalidade_id, duracao_meses, taxa_adesao) VALUES
(1, 48, 12, 50.00),
(2, 47, 6, 30.00),
(3, 46, 12, 0.00),
(4, 46, 3, 0.00);
