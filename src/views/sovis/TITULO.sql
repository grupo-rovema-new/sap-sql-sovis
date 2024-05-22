CREATE OR REPLACE VIEW TITULO AS
SELECT DISTINCT 
	(titulo."DocNum" || '-' || titulo."ObjType"  || '-' ||parcela."InstlmntID") AS "IDTITULOERP", 
	titulo."CardCode" AS "IDCLIENTEERP", 
	titulo."DocNum" AS "NUMEROTITULO", 
	titulo."DocDate" AS "DATAEMISSAO", 
	parcela."DueDate" AS "DATAVENCIMENTO" ,
	parcela."InstlmntID" AS "SEQUENCIA", 
	parcela."InsTotal" AS "VALORTITULO", 
	0 AS "VALORCORRIGIDO",
	CASE ltrim(rtrim(titulo."PeyMethod"))
		WHEN '' THEN 'AVISTA'
		ELSE IFNULL(titulo."PeyMethod",'AVISTA')
	END AS "IDFORMAPAGTOERP",
	titulo."Comments"  AS "OBS",
	0 AS "DIASBLOQUEIO", 
	null AS "DATAHORAPAGAMENTO",
	''  AS "IDTIPOPEDIDOERP",
	0 AS "INDICEJURO",
	'D' AS "TIPO",
	v."SlpName" 
FROM 
	OINV titulo
	INNER JOIN INV6 parcela ON titulo."DocEntry" = parcela."DocEntry" 
	LEFT JOIN RCT2 T1 ON titulo."DocEntry" = T1."DocEntry" AND T1."DocTransId" = titulo."TransId" AND T1."InstId" = parcela."InstlmntID"
	LEFT JOIN ORCT T2 ON T1."DocNum" = T2."DocEntry" AND T2."Canceled" = 'N'
	LEFT JOIN OSLP V ON V."SlpCode" = titulo."SlpCode"
WHERE
	titulo."DocStatus" = 'O'
	AND (T2."DocNum" IS NULL)
	AND parcela."InsTotal" <> '0'
	AND titulo."BPLId" IN (SELECT IDEMPRESAERP FROM EMPRESA e);