CREATE OR REPLACE VIEW PRAZOPAGTO_VA AS 
((SELECT
		"Code" || '_' || "U_prazo" AS "IDPRAZOPAGTOERP",
		t."ListName" ||' | ' ||"PymntGroup" AS "DESCRICAO",
		"LatePyChrg" AS "JURO",
		"InstNum" AS "QTDEPARCELAS",
		NULL AS "TIPO"
	FROM
		"@CONDICOESFV" cond
		INNER JOIN OCTG ON cond."U_prazo" = OCTG."GroupNum" 
		INNER JOIN OPLN t on(t."U_tipoComissao" = cond."Code")
	WHERE
		t."U_tipoComissao" IS NOT null) UNION ALL (SELECT
		CAST(OCTG."GroupNum" AS varchar)  AS "IDPRAZOPAGTOERP",
		"PymntGroup" AS "DESCRICAO","LatePyChrg" AS "JURO",
		"InstNum" AS "QTDEPARCELAS",
		NULL AS "TIPO"
	FROM
		OCTG));