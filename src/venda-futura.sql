--consulta que permite encerrar documento somente quando tem todas AS baixas de adt

SELECT
	vf."DocEntry",
	vf."U_valorProdutos",
	vf."U_cardCode", sum(adt."DrawnSum") 
FROM
	"@AR_CONTRATO_FUTURO" vf
	LEFT JOIN ODPI boleto ON vf."DocEntry" = boleto."U_venda_futura" AND boleto."DocStatus" <> 'C' AND boleto."CANCELED" = 'N'
	INNER JOIN OINV nota ON nota."U_venda_futura" = vf."DocEntry"
	INNER JOIN INV9 adt ON nota."DocEntry" = adt."DocEntry"
	LEFT JOIN RIN1 dev ON dev."BaseEntry" = nota."DocEntry" AND dev."BaseType" = nota."ObjType" 
WHERE
	(vf."U_status" = 'aberto' OR vf."DocEntry" = 22)
	AND nota.CANCELED = 'N'
	AND dev."DocEntry" IS NULL
	AND EXISTS(SELECT 1 FROM "ODPI" WHERE "ODPI"."U_venda_futura" = vf."DocEntry" AND "ODPI"."CANCELED" = 'N')
	AND boleto."DocEntry" IS NULL
GROUP BY
	vf."DocEntry", 
	vf."U_valorProdutos",
	vf."U_cardCode"
HAVING 
	vf."U_valorProdutos" = sum(adt."DrawnSum")

--adiantamentos
SELECT
	sum(adt."DrawnSum")
FROM
	OINV nota
	INNER JOIN INV9 adt ON nota."DocEntry" = adt."DocEntry"
	LEFT JOIN RIN1 dev ON dev."BaseEntry" = nota."DocEntry" AND dev."BaseType" = nota."ObjType" 
WHERE 
	nota."U_venda_futura" = 25
	AND nota.CANCELED = 'N'
	AND dev."DocEntry" IS NULL
	

SELECT * FROM INV9

	
SELECT * FROM RIN1
	
SELECT * FROM "@AR_CONTRATO_FUTURO" acf WHERE "DocEntry" = 22




