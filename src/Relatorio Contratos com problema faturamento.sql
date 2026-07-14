SELECT
	nota."U_venda_futura"                                        AS "contrato",
	nota."DocEntry"                                              AS "docEntry",
	nota."DocNum"                                                AS "docNum",
	nota."CardCode"                                              AS "cardCode",
	nota."CardName"                                              AS "cardName",
	nota."DocDate"                                               AS "docDate",
	ROUND(prod."previsto", 2)                                    AS "previsto",
	nota."BPLName",
	ROUND(nota."DocTotal" - COALESCE(nota."TotalExpns", 0), 2)   AS "faturado",
	ROUND((nota."DocTotal" - COALESCE(nota."TotalExpns", 0)) - prod."previsto", 2) AS "diferenca"
FROM
	"OINV" nota
	INNER JOIN (
		SELECT "DocEntry", sum("Quantity" * "U_preco_negociado") AS "previsto"
		FROM "INV1"
		GROUP BY "DocEntry"
	) prod ON prod."DocEntry" = nota."DocEntry"
WHERE
	nota."U_venda_futura" IS NOT NULL
	AND nota."CANCELED" = 'N'
	AND EXISTS(SELECT 1 FROM "INV1" l WHERE l."DocEntry" = nota."DocEntry" AND l."U_preco_negociado" > 0)
	AND ABS((nota."DocTotal" - COALESCE(nota."TotalExpns", 0)) - prod."previsto") > 0.01
ORDER BY
	nota."U_venda_futura",
	nota."DocEntry"
	

