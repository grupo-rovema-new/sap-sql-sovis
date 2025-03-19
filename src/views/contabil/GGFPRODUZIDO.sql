CREATE OR REPLACE  VIEW GGFPRODUZIDO AS
((SELECT
	doc."BPLId",
	'Produzido' AS nome,
	sum(linha."Quantity" * grupo."BaseQty") AS valor,
	MONTH(ordem."PostDate") AS mes,
    YEAR(ordem."PostDate") AS ano,
	YEAR(ordem."PostDate") || '-' ||MONTH(ordem."PostDate") AS "ano-mes"
FROM
	OWOR ordem
	INNER JOIN IGN1 linha on(linha."BaseEntry" = ordem."DocEntry" AND linha."BaseType" = 202) 
	INNER JOIN OIGN doc on(doc."DocEntry" = linha."DocEntry")
	INNER JOIN "UGP1" grupo ON(grupo."UgpEntry" = 4 AND grupo."UomEntry" = linha."UomEntry")
WHERE
	ordem."ItemCode" LIKE 'PAC%'
	AND linha."ItemCode" LIKE 'PAC%'
GROUP BY
	doc."BPLId",
	MONTH(ordem."PostDate"),
    YEAR(ordem."PostDate"),
	YEAR(ordem."PostDate") || '-' ||MONTH(ordem."PostDate")) UNION (SELECT
	doc."BPLId",
	'Estorno Produção' AS nome,
	-sum(linha."Quantity" * grupo."BaseQty") AS valor,
	MONTH(ordem."PostDate") AS mes,
    YEAR(ordem."PostDate") AS ano,
	YEAR(ordem."PostDate") || '-' ||MONTH(ordem."PostDate") AS "ano-mes"
FROM
	OWOR ordem
	INNER JOIN IGE1 linha on(linha."BaseEntry" = ordem."DocEntry" AND linha."BaseType" = 202) 
	INNER JOIN OIGE doc on(doc."DocEntry" = linha."DocEntry")
	INNER JOIN "UGP1" grupo ON(grupo."UgpEntry" = 4 AND grupo."UomEntry" = linha."UomEntry")
WHERE
	ordem."ItemCode" LIKE 'PAC%'
	AND linha."ItemCode" LIKE 'PAC%'
GROUP BY
	doc."BPLId",
	MONTH(ordem."PostDate"),
    YEAR(ordem."PostDate"),
	YEAR(ordem."PostDate") || '-' ||MONTH(ordem."PostDate")));