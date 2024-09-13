CREATE OR REPLACE VIEW ESTADO AS
SELECT
	T0."Code" AS "IDESTADOERP",-- O sovis so aceita 2 caracteres na descricao do estado!
	T0."Code" AS "DESCRICAO"
FROM
	OCST T0 
	WHERE LENGTH(T0."Code") <= 2 AND T0."Country" = 'BR';