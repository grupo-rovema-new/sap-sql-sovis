CREATE OR REPLACE VIEW EntregaFuturaSemLcBaixaPassivo AS
	SELECT
		nf."DocEntry",
		nf."DocNum",
		nf."DocDate",
		"Serial",
		nF."BPLName",
		nf."CardName" 
	FROM
		"ODLN" nf
		INNER JOIN "DLN1" it on(nf."DocEntry" = it."DocEntry")
	WHERE
		NOT EXISTS(SELECT "Ref2" FROM "OJDT" WHERE "Ref2" = CAST(nf."DocEntry" AS Varchar))
		AND it."Usage" in(17)
	GROUP BY
		nf."DocEntry",
		nf."DocNum",
		nf."DocDate",
		"Serial",
		nF."BPLName",
		nf."CardName" 
	ORDER BY
		"DocDate" DESC
	
	
	