CREATE OR REPLACE VIEW STATUSWF AS
SELECT
	'1' AS "IDSTATUSWFERP",
	'Em negociação' AS "NOME",
	'Pedido criado mas não faturado' AS "DESCRICAO"
FROM
	DUMMY
UNION ALL
SELECT
	'2' AS "IDSTATUSWFERP",
	'Faturado' AS "NOME",
	'Pedido já faturado' AS "DESCRICAO"
FROM
	DUMMY
UNION ALL
SELECT
	'3' AS "IDSTATUSWFERP",
	'Cancelado' AS "NOME",
	'Pedido Cancelado' AS "DESCRICAO"
FROM
	DUMMY
UNION ALL
SELECT
	'4' AS "IDSTATUSWFERP",
	'Aguardando aprovação Fin.' AS "NOME",
	'O pedido entro em um processo de autorização para liberação de credito' AS "DESCRICAO"
FROM
	DUMMY
UNION ALL
SELECT
	'5' AS "IDSTATUSWFERP",
	'Analise Comercial' AS "NOME",
	'Pedido recebido e esta sendo validado pelo comercial' AS "DESCRICAO"
FROM
	DUMMY
UNION ALL
SELECT
	'6' AS "IDSTATUSWFERP",
	'Pronto Para Faturar' AS "NOME",
	'Pedido foi aprovado pelo comercial e financeiro e esta pronto para faturar' AS "DESCRICAO"
FROM
	DUMMY	
UNION ALL
SELECT
	'7' AS "IDSTATUSWFERP",
	'Financeiro nao aprovado' AS "NOME",
	'Financeiro nao aprova o pedido de venda' AS "DESCRICAO"
FROM
	DUMMY	
UNION ALL
SELECT
	'8' AS "IDSTATUSWFERP",
	'Status Desconhecido' AS "NOME",
	'A foi possivel determinar o status do pedido' AS "DESCRICAO"
FROM
	DUMMY	
		
		
		
		