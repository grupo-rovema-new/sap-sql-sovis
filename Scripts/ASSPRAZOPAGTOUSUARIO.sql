CREATE OR REPLACE VIEW ASSPRAZOPAGTOUSUARIO AS
SELECT
	cond."Code" || '_' || "U_prazo" AS "IDPRAZOPAGTOERP",
	us.IDUSUARIOERP AS "IDUSUARIOERP"
FROM
	OPLN c
	INNER JOIN TABPRECO t on(c."ListNum" = t."IDTABPRECOERP")
	INNER JOIN "@LIBERAPARA" l on(l."Code" = c."U_tipoComissao")
	INNER JOIN "@CONDICOESFV" cond on(cond."Code" = c."U_tipoComissao")
	INNER JOIN "ASSUSUARIOEMPRESA" us on(us."IDEMPRESAERP" = l."U_Filial")
UNION
SELECT
	cond."Code" || '_' || "U_prazo" AS "IDPRAZOPAGTOERP",
	us.IDUSUARIOERP AS "IDUSUARIOERP"
FROM
	OPLN c
	INNER JOIN TABPRECO t on(c."ListNum" = t."IDTABPRECOERP")
	INNER JOIN "@LIBERAPARA" l on(l."Code" = c."U_tipoComissao")
	INNER JOIN "@CONDICOESFV" cond on(cond."Code" = c."U_tipoComissao")
	INNER JOIN "USUARIO" us on(us."IDUSUARIOERP" = l."U_vendedor")