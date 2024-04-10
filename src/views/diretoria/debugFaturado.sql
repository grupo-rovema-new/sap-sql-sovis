SELECT "BPLName", 
	REPLACE(sum(faturado),'.',',') AS "faturado",
	REPLACE(sum(faturado)+sum(frete),'.',',') AS "faturado com frete",
	REPLACE(sum(faturado)+sum(frete)-sum(descFin),'.',',') AS "Fat com frete sem Disct Fim",
	REPLACE(sum(faturado)-sum(descFin),'.',',') AS "faturado SEM desconto financeiro",
	REPLACE(sum(faturado)+sum(descFin),'.',',') AS "faturado com desconto financeiro",
	REPLACE(sum(faturado)+sum(descProd),'.',',') AS "faturado com desconto produtos",
	REPLACE(sum(faturado)+sum(descFin)+sum(descProd),'.',',') AS "faturado com desconto",
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
		max("Desconto Financeiro") descFin,
		max(COALESCE(frete,0)) frete
	FROM
		faturamentoAndrew AS f
	WHERE 
		f.CFOP in(5101,5116,5102,6116,6101,6109,5109,6102,6108)
		AND "DocDate" >= '2023-12-01'
		AND "DocDate" <= '2023-12-31'
		AND "faturado" > 0
	GROUP BY
		f."BPLName",
		"PK")
GROUP BY
	"BPLName"
ORDER BY 
	sum(faturado) DESC

	
	
SELECT 
	"PK",
	"Serial",
	sum(faturado),
	sum(faturado)+COALESCE(sum(frete),0),
	sum(faturado)+COALESCE(sum(frete),0)-sum(descFin) "fat. com frete sem desc. fim",
	REPLACE(sum(faturado)+sum(descProd),'.',',') AS "faturado com desconto Produto",
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
		max("Desconto Financeiro") descFin,
		max(frete) frete
	FROM
		faturamentoAndrew AS f
	WHERE 
		f.CFOP in(5101,5116,5102,6116,6101,6109,5109,6102,6108)
		AND "DocDate" >= '2023-01-01'
		AND "DocDate" <= '2023-02-28'
		AND "BPLName" LIKE '%SUSTENNUTRI NUTRICAO ANIMAL LTDA - Filial - RO%'
		AND "faturado" > 0
	GROUP BY
		f."Serial",
		"PK")
GROUP BY
	"PK",
	"Serial"
ORDER BY 
	"Serial" ASC
		
	

	
	
	
	
	
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
	
	
	

SELECT sum("Price"*"Quantity"*"DiscPrcnt"/100)  FROM INV1 WHERE "DocEntry" = 31154
-- 31154




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
	
	
	
SELECT DISTINCT 
	CASE
		WHEN "BPLName" = 'SUSTENNUTRI NUTRICAO ANIMAL LTDA - Matriz' THEN '01 - FABRICA'
		WHEN "BPLName" = 'SUSTENNUTRI NUTRICAO ANIMAL LTDA - Filial - RO' THEN '03 - CD PORTO VELHO' 
		WHEN "BPLName" = 'SUSTENNUTRI NUTRICAO ANIMAL LTDA - Filial - AC' THEN '02 - CD RIO BRANCO'
		WHEN "BPLName" = 'SUSTENNUTRI NUTRIÇAO ANIMAL LTDA - Filial Cacoal' THEN '04 - CD CACOAL'
		WHEN "BPLName" = 'SUSTENNUTRI NUTRICAO ANIMAL LTDA - Filial Roraima' THEN '05 - RORAIMA'
	END filial,
	"Serial"
FROM
	faturamentoAndrew
	WHERE
		"BPLName" = 'SUSTENNUTRI NUTRICAO ANIMAL LTDA - Filial - RO'
		AND "DocDate" >= '2023-01-01'
		AND "DocDate" <= '2023-02-28'
		AND CFOP in(5101,5116,5102,6116,6101,6109,5109,6102,6108)
	



	