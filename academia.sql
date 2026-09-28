CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL, 
    telefone VARCHAR(11) NOT NULL, 
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) UNIQUE NOT NULL,
    valor_mensal_base DECIMAL(10,2) NOT NULL CHECK (valor_mensal_base > 0)
);

CREATE TABLE modalidades (
    id SERIAL PRIMARY KEY,
    plano_id INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    sala VARCHAR(50) NOT NULL, 
    capacidade_maxima INT NOT NULL CHECK (capacidade_maxima > 0),
    disponível BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_modalidades_planos FOREIGN KEY (plano_id) REFERENCES planos(id)
);

CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    aluno_id INT NOT NULL,
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativa' CHECK (status IN ('Ativa', 'Cancelada', 'Trancada')),
    CONSTRAINT fk_matriculas_alunos FOREIGN KEY (aluno_id) REFERENCES alunos(id)
);

CREATE TABLE itens_matriculas (
    id SERIAL PRIMARY KEY,
    matricula_id INT NOT NULL,
    modalidade_id INT NOT NULL,
    duracao_meses INT NOT NULL CHECK (duracao_meses > 0),
    valor_mensal_aplicado DECIMAL(10,2) NOT NULL CHECK (valor_mensal_aplicado > 0),
    taxa_adesao DECIMAL(10,2) DEFAULT 0.00 CHECK (taxa_adesao >= 0),
    CONSTRAINT fk_itens_matriculas_matricula FOREIGN KEY (matricula_id) REFERENCES matriculas(id),
    CONSTRAINT fk_itens_matriculas_modalidade FOREIGN KEY (modalidade_id) REFERENCES modalidades(id)
);

INSERT INTO planos (nome, valor_mensal_base) VALUES
('Basic Fit', 89.90),
('Fitness Standard', 120.00),
('VIP Premium', 250.00);

INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima, disponível) VALUES
(1, 'Musculação Livre', 'Arena 01', 50, TRUE),
(2, 'Crossfit Pro', 'Estúdio 01', 20, TRUE),
(3, 'Pilates Avançado', 'Estúdio 02', 10, TRUE);

INSERT INTO alunos (nome, email, cpf, telefone) VALUES
('Carlos Eduardo', 'carlos@email.com', '12345678901', '11988887777'),
('Mariana Lima', 'mariana@email.com', '98765432100', '11977776666'),
('Roberto Souza', 'roberto@email.com', '45678912300', '11966665555');

INSERT INTO matriculas (aluno_id, status) VALUES
(1, 'Ativa'),
(2, 'Ativa'),
(3, 'Ativa'),
(1, 'Cancelada');

INSERT INTO itens_matriculas (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) VALUES
(1, 3, 12, 250.00, 50.00),
(2, 2, 6, 120.00, 30.00),
(3, 1, 12, 89.90, 0.00),
(4, 1, 3, 89.90, 0.00);

CREATE OR REPLACE VIEW vw_modalidades_custo_estimado AS
SELECT 
    m.nome AS modalidade,
    m.sala,
    p.nome AS plano,
    ROUND(p.valor_mensal_base * 1.10, 2) AS valor_mensal_ajustado
FROM modalidades m
JOIN planos p ON m.plano_id = p.id
ORDER BY valor_mensal_ajustado DESC;

CREATE OR REPLACE VIEW vw_matriculas_ativas AS
SELECT 
    a.nome AS aluno_nome,
    a.cpf,
    m.nome AS modalidade_nome,
    m.sala,
    im.duracao_meses,
    mat.data_inicio
FROM matriculas mat
JOIN alunos a ON mat.aluno_id = a.id
JOIN itens_matriculas im ON im.matricula_id = mat.id
JOIN modalidades m ON im.modalidade_id = m.id
WHERE mat.status = 'Ativa';

CREATE OR REPLACE VIEW vw_alunos_vip AS
SELECT 
    a.nome AS aluno_nome,
    COUNT(mat.id) AS qtd_contratos_ativos,
    SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) AS valor_total_investido
FROM alunos a
JOIN matriculas mat ON mat.aluno_id = a.id
JOIN itens_matriculas im ON im.matricula_id = mat.id
WHERE mat.status = 'Ativa'
GROUP BY a.id, a.nome
HAVING SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) > 1000.00;

SELECT 
    m.id,
    m.nome AS modalidade,
    m.sala,
    m.capacidade_maxima,
    p.nome AS plano,
    p.valor_mensal_base
FROM modalidades m
JOIN planos p ON m.plano_id = p.id
WHERE m.capacidade_maxima >= 15
  AND p.valor_mensal_base > 100.00
  AND m.disponível = TRUE;

CREATE OR REPLACE VIEW vw_faturamento_medio_plano AS
SELECT 
    p.nome AS plano_nome,
    COALESCE(SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao), 0.00) AS faturamento_total_acumulado,
    ROUND(AVG(im.duracao_meses), 2) AS media_duracao_meses
FROM planos p
JOIN modalidades m ON m.plano_id = p.id
JOIN itens_matriculas im ON im.modalidade_id = m.id
JOIN matriculas mat ON im.matricula_id = mat.id
WHERE mat.status = 'Ativa'
GROUP BY p.id, p.nome;