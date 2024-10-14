CREATE OR REPLACE VIEW MOTIVONAOVENDA AS
SELECT
	'001' AS "IDMOTIVONAOVENDAERP",
	'Cliente sem necessidade no momento' AS "DESCRICAO",
	1 AS "SITUACAO",
	0 AS "OBRIGACONTATO",
	0 AS "OBRIGAOBSERVACAO",
	0 AS "MINIMOFOTOS",
	0 AS "OCULTACONTATO",
	0 AS "OCULTAOBSERVACAO",
	0 AS "OCULTAFOTOS"
FROM
	dummy
UNION
SELECT
	'002',
	'Orçamento insuficiente',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy
UNION
SELECT
	'003',
	'Produto fora de estoque',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy
UNION
SELECT
	'004',
	'Concorrência mais barata',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy
UNION
SELECT
	'005',
	'Produto não atende à necessidade',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy
UNION
SELECT
	'006',
	'Cliente insatisfeito com o serviço',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy
UNION
SELECT
	'007',
	'Dificuldades de entrega',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy
	UNION
SELECT
	'008',
	'Crédito insuficiente',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy
	UNION
SELECT
	'009',
	'Preferência por outro fornecedor',
	1,
	0,
	0,
	0,
	0,
	0,
	0
FROM
	dummy;