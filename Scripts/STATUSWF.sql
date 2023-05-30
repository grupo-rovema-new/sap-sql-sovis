CREATE OR REPLACE VIEW STATUSWF AS
SELECT
'1' AS "IDSTATUSWFERP",
'Em negociação' AS "NOME",
'Pedido criado mas não faturado' AS "DESCRICAO"
FROM DUMMY
UNION ALL
SELECT
'2' AS "IDSTATUSWFERP",
'Faturado' AS "NOME",
'Pedido já faturado' AS "DESCRICAO"
FROM DUMMY
UNION ALL
SELECT
'3' AS "IDSTATUSWFERP",
'Cancelado' AS "NOME",
'Pedido Cancelado' AS "DESCRICAO"
FROM DUMMY
UNION ALL
SELECT
'4' AS "IDSTATUSWFERP",
'Aguardando aprovação' AS "NOME",
'O pedido entro em um processo de autorização para liberação de credito' AS "DESCRICAO"
FROM DUMMY