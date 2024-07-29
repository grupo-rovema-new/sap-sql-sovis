CREATE OR REPLACE VIEW SBOGRUPOROVEMA.TITULOANOTACAO AS
SELECT
	titulo."DocEntry" AS "IDTITULOANOTACAOERP",
	   (titulo."DocNum" || '-' || titulo."ObjType" || '-' || parcela."InstlmntID") AS "IDTITULOERP",
	   titulo."UserSign" AS "USUARIO",
	   titulo."DocDate" AS "DATAHORA",
	   titulo."Comments" AS "ANOTACAO"
FROM
	OINV titulo
INNER JOIN INV6 parcela ON
	titulo."DocEntry" = parcela."DocEntry"
LEFT JOIN RCT2 T1 ON
	titulo."DocEntry" = T1."DocEntry"
	AND T1."DocTransId" = titulo."TransId"
	AND T1."InstId" = parcela."InstlmntID"
LEFT JOIN ORCT T2 ON
	T1."DocNum" = T2."DocEntry"
	AND T2."Canceled" = 'N'
WHERE
	titulo."DocNum" IN (
	SELECT
		t."NUMEROTITULO"
	FROM
		TITULO t)
	AND titulo."DocStatus" = 'O'
	AND (T2."DocNum" IS NULL)
	AND parcela."InsTotal" <> '0'
	AND titulo."BPLId" IN (
	SELECT
		IDEMPRESAERP
	FROM
		EMPRESA e);