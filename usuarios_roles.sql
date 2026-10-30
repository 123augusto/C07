-- C07 | Segunda entrega | Usuarios e ROLE | MySQL 8.0+
-- Executar DEPOIS de segundaEntrega.sql, com conta administradora.
-- Cria contas LOCAIS de demonstracao; as senhas abaixo sao didaticas.
-- Antes de usar fora do ambiente de aula, substitua as duas senhas.
-- Executar uma unica vez. Nao remove nem altera contas que ja existam.
USE festival_inovacao_segunda_entrega;

CREATE ROLE 'r_recepcao_festival'@'%';

CREATE USER 'recepcao_ana'@'localhost'
  IDENTIFIED BY 'Didatico_Ana#2026!';
CREATE USER 'recepcao_bruno'@'localhost'
  IDENTIFIED BY 'Didatico_Bruno#2026!';

-- A ROLE pode consultar o projeto e registrar presenca.
-- O UPDATE fica limitado a coluna status_checkin.
GRANT SELECT ON festival_inovacao_segunda_entrega.*
  TO 'r_recepcao_festival'@'%';
GRANT UPDATE (status_checkin)
  ON festival_inovacao_segunda_entrega.inscricoes_atividade
  TO 'r_recepcao_festival'@'%';
GRANT EXECUTE ON PROCEDURE festival_inovacao_segunda_entrega.sp_registrar_checkin
  TO 'r_recepcao_festival'@'%';
GRANT EXECUTE ON FUNCTION festival_inovacao_segunda_entrega.fn_percentual_presenca
  TO 'r_recepcao_festival'@'%';

-- As duas contas recebem o mesmo conjunto de permissoes por meio da ROLE.
GRANT 'r_recepcao_festival'@'%'
  TO 'recepcao_ana'@'localhost', 'recepcao_bruno'@'localhost';

-- Torna a ROLE ativa automaticamente nas proximas conexoes.
SET DEFAULT ROLE 'r_recepcao_festival'@'%'
  TO 'recepcao_ana'@'localhost', 'recepcao_bruno'@'localhost';

SHOW GRANTS FOR 'r_recepcao_festival'@'%';
SHOW GRANTS FOR 'recepcao_ana'@'localhost';
SHOW GRANTS FOR 'recepcao_bruno'@'localhost';

-- Para demonstrar em uma NOVA conexao com cada usuario:
-- SELECT CURRENT_USER(), CURRENT_ROLE();
-- SELECT * FROM festival_inovacao_segunda_entrega.vw_resumo_atividades;
-- SELECT festival_inovacao_segunda_entrega.fn_percentual_presenca(3, 4);
-- CALL festival_inovacao_segunda_entrega.sp_registrar_checkin(8, 1);
