SELECT
	r."CardCode",
	cp.CPFCNPJ,
	bp."U_dataSerasa",
	bp.*
FROM 
	OWDD a
	INNER JOIN ODRF r ON r."DocEntry" = a."DraftEntry" 
	INNER JOIN OCRD bp ON bp."CardCode" = r."CardCode"
	LEFT JOIN BpCpfCnpj cp ON bp."CardCode" = cp."CardCode"
WHERE
	"WtmCode" = 26
	AND "Status" = 'W'
	AND "ProcesStat" = 'W'
	AND a."DocDate" > '2024-01-01 00:00:00.000'
	AND (bp."U_dataSerasa" < '2024-01-06' OR bp."U_dataSerasa" IS NULL)vou 