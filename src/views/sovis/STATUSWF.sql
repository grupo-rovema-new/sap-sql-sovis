CREATE OR REPLACE VIEW STATUSWF AS
SELECT
	'1' AS "IDSTATUSWFERP",
	'PEDIDO_Em negociação' AS "NOME",
	'Pedido criado mas não faturado' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'NE' AS sigla
FROM
	DUMMY
UNION ALL
SELECT
	'2' AS "IDSTATUSWFERP",
	'PEDIDO_Faturado' AS "NOME",
	'Pedido já faturado' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'FA' AS sigla
FROM
	DUMMY
UNION ALL
SELECT
	'3' AS "IDSTATUSWFERP",
	'PEDIDO_Cancelado' AS "NOME",
	'Pedido Cancelado' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'CA' AS sigla
FROM
	DUMMY
UNION ALL
SELECT
	'4' AS "IDSTATUSWFERP",
	'PEDIDO_Aguardando aprovação Fin.' AS "NOME",
	'O pedido entro em um processo de autorização para liberação de credito' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'AU' AS sigla
FROM
	DUMMY
UNION ALL
SELECT
	'5' AS "IDSTATUSWFERP",
	'PEDIDO_Analise Comercial' AS "NOME",
	'Pedido recebido e esta sendo validado pelo comercial' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'AC' AS sigla
FROM
	DUMMY
UNION ALL
SELECT
	'6' AS "IDSTATUSWFERP",
	'PEDIDO_Pronto Para Faturar' AS "NOME",
	'Pedido foi aprovado pelo comercial e financeiro e esta pronto para faturar' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'PF' AS sigla
FROM
	DUMMY	
UNION ALL
SELECT
	'7' AS "IDSTATUSWFERP",
	'PEDIDO_Financeiro nao aprovado' AS "NOME",
	'Financeiro nao aprova o pedido de venda' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'FN' AS sigla
FROM
	DUMMY	
UNION ALL
SELECT
	'8' AS "IDSTATUSWFERP",
	'PEDIDO_Status Desconhecido' AS "NOME",
	'A foi possivel determinar o status do pedido' AS "DESCRICAO",
	0 AS NOTIFICA_CLIENTE,
	'DE' AS sigla
FROM
	DUMMY	
	

	
	
		