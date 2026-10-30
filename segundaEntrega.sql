-- C07 | Segunda entrega | Festival de Inovacao

-- 1. BANCO E TABELAS (DDL)
CREATE DATABASE festival_inovacao_segunda_entrega;
USE festival_inovacao_segunda_entrega;

CREATE TABLE pessoa (
  id_pessoa INT AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  telefone VARCHAR(15),
  PRIMARY KEY (id_pessoa)
) ENGINE = InnoDB;

-- Heranca: o identificador herdado e, simultaneamente, PK e FK.
CREATE TABLE palestrante (
  id_pessoa INT,
  minicurriculo VARCHAR(255),
  area_especialidade VARCHAR(50),
  PRIMARY KEY (id_pessoa),
  CONSTRAINT fk_palestrante_pessoa FOREIGN KEY (id_pessoa)
    REFERENCES pessoa (id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE participante (
  id_pessoa INT,
  tipo_ingresso VARCHAR(20) NOT NULL,
  PRIMARY KEY (id_pessoa),
  CONSTRAINT fk_participante_pessoa FOREIGN KEY (id_pessoa)
    REFERENCES pessoa (id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE espaco (
  id_espaco INT AUTO_INCREMENT,
  nome_local VARCHAR(50) NOT NULL,
  capacidade_maxima INT NOT NULL,
  PRIMARY KEY (id_espaco)
) ENGINE = InnoDB;

CREATE TABLE atividade (
  id_atividade INT AUTO_INCREMENT,
  titulo VARCHAR(150) NOT NULL,
  descricao VARCHAR(255),
  duracao_minutos INT,
  data_hora_inicio DATETIME NOT NULL,
  id_espaco INT,
  id_palestrante INT,
  id_atividade_prerequisito INT,
  PRIMARY KEY (id_atividade),
  CONSTRAINT fk_atividade_espaco FOREIGN KEY (id_espaco)
    REFERENCES espaco (id_espaco)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_atividade_palestrante FOREIGN KEY (id_palestrante)
    REFERENCES palestrante (id_pessoa)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_atividade_prerequisito FOREIGN KEY (id_atividade_prerequisito)
    REFERENCES atividade (id_atividade)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

-- N:M: a mesma pessoa pode participar de varias atividades e vice-versa.
CREATE TABLE inscricoes_atividade (
  id_participante INT,
  id_atividade INT,
  data_inscricao DATETIME,
  status_checkin BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id_participante, id_atividade),
  CONSTRAINT fk_inscricao_participante FOREIGN KEY (id_participante)
    REFERENCES participante (id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_inscricao_atividade FOREIGN KEY (id_atividade)
    REFERENCES atividade (id_atividade)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- 1:1: UNIQUE limita a uma credencial por participante.
-- NOT NULL exige que toda credencial esteja associada a um participante.
CREATE TABLE credencial (
  id_credencial INT AUTO_INCREMENT,
  codigo VARCHAR(30) NOT NULL UNIQUE,
  id_participante INT NOT NULL UNIQUE,
  PRIMARY KEY (id_credencial),
  CONSTRAINT fk_credencial_participante FOREIGN KEY (id_participante)
    REFERENCES participante (id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- 2. TRIGGER
-- Proposta: preencher a data da inscricao quando ela nao for informada.
-- Base: Aula 09, NEW/SET NEW/IF e NOW; Aula 08, IS NULL.
DELIMITER $$
CREATE TRIGGER trg_inscricao_data
BEFORE INSERT ON inscricoes_atividade
FOR EACH ROW
BEGIN
  IF NEW.data_inscricao IS NULL THEN
    SET NEW.data_inscricao = NOW();
  END IF;
END$$
DELIMITER ;

-- 3. INSERCAO DE DADOS (DML)
-- IDs explicitos tornam os exemplos e os resultados reproduziveis.
-- As datas da carga inicial sao informadas explicitamente.
START TRANSACTION;

INSERT INTO pessoa (id_pessoa, nome, email, telefone) VALUES
  (1, 'Ana Melo', 'ana.melo@example.com', '11900000001'),
  (2, 'Bruno Lima', 'bruno.lima@example.com', '11900000002'),
  (3, 'Carla Souza', 'carla.souza@example.com', '11900000003'),
  (4, 'Diego Alves', 'diego.alves@example.com', '11900000004'),
  (5, 'Elisa Rocha', 'elisa.rocha@example.com', '11900000005'),
  (6, 'Felipe Costa', 'felipe.costa@example.com', '11900000060'),
  (7, 'Gabriela Dias', 'gabriela.dias@example.com', '11900000007'),
  (8, 'Henrique Reis', 'henrique.reis@example.com', '11900000008'),
  (9, 'Isabela Nunes', 'isabela.nunes@example.com', '11900000009'),
  (10, 'Joao Martins', 'joao.martins@example.com', '11900000010'),
  (11, 'Luiza Freitas', 'luiza.freitas@example.com', '11900000011');

INSERT INTO palestrante (id_pessoa, minicurriculo, area_especialidade) VALUES
  (1, 'Pesquisadora de sistemas inteligentes.', 'Inteligencia artificial'),
  (2, 'Professor de robotica educacional.', 'Robotica'),
  (3, 'Desenvolvedora de produtos acessiveis.', 'Engenharia de software'),
  (4, 'Mentor de projetos de inovacao.', 'Empreendedorismo'),
  (5, 'Engenheira de redes e infraestrutura.', 'Redes de computadores');

INSERT INTO participante (id_pessoa, tipo_ingresso) VALUES
  (6, 'Estudante'), (7, 'Profissional'), (8, 'Estudante'),
  (9, 'Estudante'), (10, 'Profissional'), (11, 'Estudante');

INSERT INTO espaco (id_espaco, nome_local, capacidade_maxima) VALUES
  (1, 'Auditorio principal', 120),
  (2, 'Laboratorio de robotica', 40),
  (3, 'Sala de desenvolvimento', 60),
  (4, 'Sala de empreendedorismo', 80),
  (5, 'Sala de apoio', 30);

-- atividades sem pre-requisito.
INSERT INTO atividade
  (id_atividade, titulo, descricao, duracao_minutos, data_hora_inicio, id_espaco, id_palestrante, id_atividade_prerequisito) VALUES
  (1, 'Introducao a sistemas inteligentes', 'Conceitos e exemplos de aplicacao.',
   60, '2026-11-20 09:00:00', 1, 1, NULL),
  (3, 'Software acessivel', 'Praticas de acessibilidade em produtos digitais.',
   90, '2026-11-20 10:30:00', 3, 3, NULL),
  (4, 'Empreender com inovacao', 'Discussao de propostas de novos negocios.',
   60, '2026-11-20 13:00:00', 4, 4, NULL),
  (6, 'Mostra de projetos', 'Atividade ainda sem espaco e palestrante definidos.',
   120, '2026-11-20 16:00:00', NULL, NULL, NULL);

-- Autorrelacionamento: as atividades 2 e 5 apontam para a atividade 1.
INSERT INTO atividade
  (id_atividade, titulo, descricao, duracao_minutos, data_hora_inicio,
   id_espaco, id_palestrante, id_atividade_prerequisito)
VALUES
  (2, 'Robotica na pratica', 'Montagem e demonstracao de prototipos.',
   90, '2026-11-20 14:30:00', 2, 2, 1),
  (5, 'Redes para projetos conectados', 'Fundamentos de comunicacao entre dispositivos.',
   60, '2026-11-20 11:30:00', 1, 5, 1);

INSERT INTO credencial (id_credencial, codigo, id_participante) VALUES
  (1, 'FEST-2026-006', 6), (2, 'FEST-2026-007', 7),
  (3, 'FEST-2026-008', 8), (4, 'FEST-2026-009', 9),
  (5, 'FEST-2026-010', 10);

INSERT INTO inscricoes_atividade
  (id_participante, id_atividade, data_inscricao, status_checkin)
VALUES
  (6, 1, '2026-10-20 08:00:00', TRUE),
  (6, 2, '2026-10-20 08:05:00', FALSE),
  (6, 3, '2026-10-20 08:10:00', FALSE),
  (7, 1, '2026-10-21 09:00:00', TRUE),
  (7, 3, '2026-10-21 09:05:00', TRUE),
  (7, 4, '2026-10-21 09:10:00', FALSE),
  (8, 1, '2026-10-22 10:00:00', FALSE),
  (8, 2, '2026-10-22 10:05:00', FALSE),
  (8, 5, '2026-10-22 10:10:00', FALSE),
  (9, 3, '2026-10-23 11:00:00', TRUE),
  (9, 4, '2026-10-23 11:05:00', FALSE),
  (9, 5, '2026-10-23 11:10:00', FALSE),
  (10, 1, '2026-10-24 12:00:00', FALSE),
  (10, 2, '2026-10-24 12:05:00', FALSE),
  (10, 4, '2026-10-24 12:10:00', FALSE),
  (10, 5, '2026-10-24 12:15:00', TRUE);
COMMIT;

-- 4. PROCEDURE E FUNCTION
DELIMITER $$
-- Centraliza o registro de presenca em uma inscricao existente.
CREATE PROCEDURE sp_registrar_checkin (
  IN p_id_participante INT,
  IN p_id_atividade INT
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM inscricoes_atividade
    WHERE id_participante = p_id_participante
      AND id_atividade = p_id_atividade
  ) THEN
    UPDATE inscricoes_atividade
    SET status_checkin = TRUE
    WHERE id_participante = p_id_participante
      AND id_atividade = p_id_atividade;
    SELECT 'Check-in registrado.' AS resultado;
  ELSE
    SELECT 'Inscricao nao encontrada.' AS resultado;
  END IF;
END$$

-- Calculo com parametros, conforme o exemplo de function da Aula 09.
CREATE FUNCTION fn_percentual_presenca (
  p_total_checkins INT,
  p_total_inscritos INT
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
  IF p_total_inscritos = 0 THEN
    RETURN 0;
  END IF;
  RETURN p_total_checkins * 100.0 / p_total_inscritos;
END$$
DELIMITER ;

-- 5. VIEW
-- Reutiliza um relatorio de atividades, incluindo as que nao tem inscricoes.
CREATE VIEW vw_resumo_atividades AS
SELECT
  a.id_atividade, a.titulo, a.data_hora_inicio,
  e.nome_local, p.nome AS nome_palestrante,
  COUNT(i.id_participante) AS total_inscritos,
  (SELECT COUNT(*)
   FROM inscricoes_atividade AS presenca
   WHERE presenca.id_atividade = a.id_atividade
     AND presenca.status_checkin = TRUE) AS total_checkins
FROM atividade AS a
LEFT JOIN espaco AS e ON e.id_espaco = a.id_espaco
LEFT JOIN palestrante AS pal ON pal.id_pessoa = a.id_palestrante
LEFT JOIN pessoa AS p ON p.id_pessoa = pal.id_pessoa
LEFT JOIN inscricoes_atividade AS i ON i.id_atividade = a.id_atividade
GROUP BY a.id_atividade, a.titulo, a.data_hora_inicio, e.nome_local, p.nome;

-- 6. EXEMPLOS JUSTIFICADOS DE INSERT, UPDATE E DELETE
START TRANSACTION;

-- INSERT: registrar a inscricao de Luiza na atividade 1.
INSERT INTO inscricoes_atividade
  (id_participante, id_atividade, data_inscricao, status_checkin)
VALUES (11, 1, '2026-10-26 14:00:00', FALSE);
SELECT 'INSERT: inscricao cadastrada' AS demonstracao, i.*
FROM inscricoes_atividade AS i
WHERE id_participante = 11 AND id_atividade = 1;

-- UPDATE: corrigir o telefone cadastrado de Felipe, sem recriar a pessoa.
UPDATE pessoa SET telefone = '11900000006' WHERE id_pessoa = 6;
SELECT 'UPDATE: telefone corrigido' AS demonstracao, id_pessoa, nome, telefone
FROM pessoa WHERE id_pessoa = 6;

-- DELETE: cancelar somente a inscricao de Luiza, mantendo seu cadastro.
DELETE FROM inscricoes_atividade
WHERE id_participante = 11 AND id_atividade = 1;
SELECT 'DELETE: deve retornar zero' AS demonstracao, COUNT(*) AS inscricoes_restantes
FROM inscricoes_atividade WHERE id_participante = 11 AND id_atividade = 1;
COMMIT;

-- Exemplo da procedure: registra a presenca de Henrique na atividade 1.
CALL sp_registrar_checkin(8, 1);

-- 7. CONSULTAS COMPLEXAS COM JOIN

-- Q1 | Relacionamento 1:1: participantes e respectivas credenciais.
-- LEFT JOIN permite mostrar Luiza, que ainda nao possui credencial.
SELECT p.id_pessoa, p.nome, par.tipo_ingresso, c.codigo AS credencial
FROM participante AS par
INNER JOIN pessoa AS p ON p.id_pessoa = par.id_pessoa
LEFT JOIN credencial AS c ON c.id_participante = par.id_pessoa
ORDER BY p.nome;

-- Q2 | Relacionamentos 1:N: quantidade de atividades por espaco.
-- COUNT(a.id_atividade) retorna zero para um espaco sem atividade.
SELECT e.id_espaco, e.nome_local, e.capacidade_maxima,
       COUNT(a.id_atividade) AS total_atividades,
       SUM(a.duracao_minutos) AS minutos_programados
FROM espaco AS e
LEFT JOIN atividade AS a ON a.id_espaco = e.id_espaco
GROUP BY e.id_espaco, e.nome_local, e.capacidade_maxima
ORDER BY total_atividades DESC, e.nome_local;

-- Q3 | Relacionamento N:M: participantes com pelo menos tres inscricoes.
-- A tabela associativa conecta participante e atividade.
SELECT p.id_pessoa, p.nome, COUNT(i.id_atividade) AS total_inscricoes,
       SUM(a.duracao_minutos) AS minutos_inscritos,
       (SELECT COUNT(*)
        FROM inscricoes_atividade AS presenca
        WHERE presenca.id_participante = p.id_pessoa
          AND presenca.status_checkin = TRUE) AS checkins_realizados
FROM participante AS par
INNER JOIN pessoa AS p ON p.id_pessoa = par.id_pessoa
INNER JOIN inscricoes_atividade AS i ON i.id_participante = par.id_pessoa
INNER JOIN atividade AS a ON a.id_atividade = i.id_atividade
GROUP BY p.id_pessoa, p.nome
HAVING COUNT(i.id_atividade) >= 3
ORDER BY total_inscricoes DESC, p.nome;

-- Q4 | Integra 1:1, 1:N e N:M na mesma consulta.
-- Lista as presencas confirmadas e os dados operacionais do evento.
SELECT pp.nome AS participante, c.codigo AS credencial, a.titulo AS atividade,
       e.nome_local, pl.nome AS palestrante, i.data_inscricao
FROM inscricoes_atividade AS i
INNER JOIN participante AS par ON par.id_pessoa = i.id_participante
INNER JOIN pessoa AS pp ON pp.id_pessoa = par.id_pessoa
INNER JOIN atividade AS a ON a.id_atividade = i.id_atividade
LEFT JOIN credencial AS c ON c.id_participante = par.id_pessoa
LEFT JOIN espaco AS e ON e.id_espaco = a.id_espaco
LEFT JOIN palestrante AS pal ON pal.id_pessoa = a.id_palestrante
LEFT JOIN pessoa AS pl ON pl.id_pessoa = pal.id_pessoa
WHERE i.status_checkin = TRUE
ORDER BY a.data_hora_inicio, pp.nome;

-- Q5 | Extra: autorrelacionamento, com dois papeis da tabela atividade.
SELECT a.titulo AS atividade, pre.titulo AS prerequisito
FROM atividade AS a
INNER JOIN atividade AS pre ON pre.id_atividade = a.id_atividade_prerequisito
ORDER BY a.id_atividade;

-- Q6 | Extra: participantes sem nenhuma inscricao (anti-join).
SELECT p.id_pessoa, p.nome
FROM participante AS par
INNER JOIN pessoa AS p ON p.id_pessoa = par.id_pessoa
LEFT JOIN inscricoes_atividade AS i ON i.id_participante = par.id_pessoa
WHERE i.id_atividade IS NULL
ORDER BY p.nome;

-- 8. DEMONSTRACAO DOS OBJETOS E CONFERENCIA FINAL
SELECT * FROM vw_resumo_atividades ORDER BY id_atividade;
SELECT id_atividade, titulo, total_inscritos, total_checkins,
       fn_percentual_presenca(total_checkins, total_inscritos) AS percentual_presenca
FROM vw_resumo_atividades
ORDER BY id_atividade;

-- Mostra as subclasses recuperando os atributos herdados da superclasse.
SELECT p.id_pessoa, p.nome, p.email, pal.area_especialidade
FROM pessoa AS p INNER JOIN palestrante AS pal ON pal.id_pessoa = p.id_pessoa
ORDER BY p.id_pessoa;

-- Demonstra o trigger sem alterar a carga final: a data e omitida no INSERT.
START TRANSACTION;
INSERT INTO inscricoes_atividade (id_participante, id_atividade, status_checkin)
VALUES (11, 6, FALSE);
SELECT 'TRIGGER: data preenchida automaticamente' AS demonstracao,
       id_participante, id_atividade, data_inscricao
FROM inscricoes_atividade
WHERE id_participante = 11 AND id_atividade = 6;
ROLLBACK;

SELECT 'pessoa' AS tabela, COUNT(*) AS total FROM pessoa
UNION ALL SELECT 'palestrante', COUNT(*) FROM palestrante
UNION ALL SELECT 'participante', COUNT(*) FROM participante
UNION ALL SELECT 'espaco', COUNT(*) FROM espaco
UNION ALL SELECT 'atividade', COUNT(*) FROM atividade
UNION ALL SELECT 'inscricoes_atividade', COUNT(*) FROM inscricoes_atividade
UNION ALL SELECT 'credencial', COUNT(*) FROM credencial;
