CREATE OR REPLACE VIEW SITUACAO AS
	SELECT
		'Y' AS "IDSITUACAOERP" ,
 		empresa.IDEMPRESAERP  AS "IDEMPRESAERP", 
		'Ativo' AS "DESCRICAO",
 		'' AS "COR",
 		1  AS "SITUACAO" 
 	FROM
 		dummy,
 		empresa
 	UNION ALL
 	SELECT
		'N' AS "IDSITUACAOERP" ,
 		0 AS "IDEMPRESAERP", 
		'Inativo' AS "DESCRICAO",
 		'' AS "COR",
 		0  AS "SITUACAO" 
 	FROM
 		dummy,
 		empresa
