CREATE OR REPLACE VIEW notasCanceladasAtivasNaSefaz as

SELECT 
	doc."DocEntry",
	doc."DocNum",
	doc."DocDate",
	doc."Serial" AS "Numero Nota",
	sefaz."KeyNfe",
	filial."BPLName"
FROM
	"OINV" as doc
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = doc."ObjType" AND doc."DocEntry" = sefaz."DocEntry")
	INNER JOIN "OBPL" filial ON filial."BPLId" = doc."BPLId"
WHERE
	doc."CANCELED" = 'Y'
	AND sefaz."StatusId" = 4