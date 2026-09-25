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