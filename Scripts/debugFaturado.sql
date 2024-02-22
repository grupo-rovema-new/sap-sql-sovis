SELECT "BPLName", 
	REPLACE(sum(faturado),'.',',') AS "faturado",
	REPLACE(sum(faturado)+sum(descFin),'.',',') AS "faturado com desconto financeiro",
	REPLACE(sum(faturado)-sum(descFin),'.',',') AS "faturado sem desconto produto",
	sum(descProd), 
	sum(descFin), 
	sum(descProd)+sum(descFin) AS totalDesconto, 
	sum(desonerado) desonerado,
	count(1) 
FROM 
	(SELECT
		f."BPLName",
		f."PK",
		sum("faturado") faturado,
		sum("desonerado") desonerado,
		sum("Desconto Produtos") descProd,
		max("Desconto Financeiro") descFin
	FROM
		faturamentoAndrew AS f
	WHERE 
		f.CFOP in(5101,5116,5102,6116,6101,6109,5109,6102,6108)
		AND "DocDate" >= '2023-11-01'
		AND "DocDate" <= '2023-11-30'
		AND "faturado" > 0
	GROUP BY
		f."BPLName",
		"PK")
GROUP BY
	"BPLName"
ORDER BY 
	sum(faturado)-sum(descFin) DESC

	
	
SELECT 
	"PK",
	"Serial",
	sum(faturado), 
	REPLACE(sum(faturado)-sum(descFin),'.',',') AS "faturado sem desconto",
	sum(descProd) AS descProduto, 
	sum(descFin) AS descFinanceiro, 
	sum(descProd)+sum(descFin) AS totalDesconto, 
	sum(desonerado) desonerado
FROM 
	(SELECT
		f."Serial",
		f."PK",
		sum("faturado") faturado,
		sum("desonerado") desonerado,
		sum("Desconto Produtos") descProd,
		max("Desconto Financeiro") descFin
	FROM
		faturamentoAndrew AS f
	WHERE 
		f.CFOP in(5101,5116,5102,6116,6101,6109,5109,6102,6108)
		AND "DocDate" >= '2023-12-01'
		AND "DocDate" <= '2023-12-31'
		AND "BPLName" LIKE '%SUSTENNUTRI NUTRICAO ANIMAL LTDA - Filial - RO%'
		AND "faturado" > 0
	GROUP BY
		f."Serial",
		"PK")
GROUP BY
	"PK",
	"Serial"
ORDER BY 
	sum(faturado)-sum(descFin) DESC
		
	
	
	
	
	
	
	
SELECT
	f."PK",
	f."Serial",
	sum("faturado") faturado,
	sum("faturado")+sum("Desconto Produtos") AS "fatrado Sem desconto produto",
	sum("desonerado") desonerado,
	sum("Desconto Produtos") descProd
FROM
	faturamentoAndrew AS f
WHERE 
	f.CFOP in(5101,5116,5102,6116,6101,6109,5109,6102,6108)
	AND "DocDate" >= '2023-12-01'
	AND "DocDate" <= '2023-12-31'
	AND "BPLName" LIKE '%SUSTENNUTRI NUTRICAO ANIMAL LTDA - Filial - RO%'
	AND "faturado" > 0
GROUP BY
	f."Serial",
	f."PK",
	f.CFOP
ORDER BY
	sum("faturado")+sum("Desconto Produtos") DESC
	
	
SELECT
	f."PK",
	f."Serial",
	sum("faturado") faturado,
	sum("faturado")+sum("Desconto Produtos") AS "fatrado Sem desconto produto",
	sum("desonerado") desonerado,
	sum("Desconto Produtos") descProd
FROM
	faturamentoAndrew AS f
WHERE 
	f."Serial" in(4481)
	AND "faturado" > 0
GROUP BY
	f."Serial",
	f."PK",
	f.CFOP
ORDER BY
	f."Serial"


SELECT * FROM FATURAMENTOANDREW f WHERE PK like '8656-13'
	



---- Faturado por filial

SELECT
	f."BPLName",
	REPLACE((sum("faturado")-max("Desconto Financeiro")),'.',',') faturado,
	sum("Desconto Produtos") descProd,
	sum("desonerado") desonerado
FROM
	faturamentoAndrew AS f
WHERE 
	"faturado" >= 0 
	AND "DocDate" >= '2023-12-01'
	AND "DocDate" <= '2023-12-31'
	AND f.CFOP in(5101,5116,5102,6116,6101,6109,5109,6102,6108)
GROUP BY
	f."BPLName" 
ORDER BY 
	sum("faturado")-sum("Desconto Produtos") desc
	
	