CREATE OR REPLACE VIEW TIPOENDERECO AS
SELECT
	tipo."AdresType" AS "IDTIPOENDERECOERP",
	CASE
		WHEN tipo."AdresType" = 'S' THEN 'ENTREGA'
		WHEN tipo."AdresType" = 'B' THEN 'COBRANCA'
	END AS "DESCRICAO",
	CASE
		WHEN tipo."AdresType" = 'S' THEN 'E'
		WHEN tipo."AdresType" = 'B' THEN 'C'
	END AS "TIPO"
FROM
	CRD1 AS tipo
GROUP BY tipo."AdresType";