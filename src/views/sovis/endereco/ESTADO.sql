CREATE OR REPLACE VIEW ESTADO AS
SELECT
	T0."Code" AS "IDESTADOERP",
	T0."Code" AS "DESCRICAO" -- O sovis so aceita 2 caracteres na descricao do estado!
FROM
	OCST T0 
	WHERE LENGTH(T0."Code") <= 2 AND T0."Country" = 'BR';