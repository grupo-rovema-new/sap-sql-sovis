CREATE OR REPLACE VIEW PRAZOPAGTO AS 
	SELECT
		"Code" || '_' || "U_prazo" AS "IDPRAZOPAGTOERP",
		"PymntGroup" AS "DESCRICAO",
		1 AS "SITUACAO"
	FROM
		"@CONDICOESFV" cond
		INNER JOIN OCTG ON cond."U_prazo" = OCTG."GroupNum" 
	WHERE
		"Code" in(SELECT "U_tipoComissao" FROM OPLN WHERE "U_tipoComissao" IS  NOT NULL)








