

SELECT
	nf."DocEntry",
	nf."DocNum",
	nf."DocDate",
	"Serial",
	nF."BPLName",
	nf."CardName" 
FROM
	OINV nf
	INNER JOIN INV1 it on(nf."DocEntry" = it."DocEntry")
WHERE
	"isIns" = 'N'
	AND it."Usage" in(16)




