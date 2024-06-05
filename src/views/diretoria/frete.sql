CREATE OR REPLACE VIEW freteFaturamento as
SELECT
	"PK",	
	"FILIAL",
	"numeroNota",
	"data",
	SUM(frete)
FROM 
	(SELECT
		f."FILIAL",
		f."PK",
		f."numeroNota",
		"data",
		max(COALESCE(frete,0)) frete
	FROM
		faturamentoAndrew AS f
	GROUP BY
		f."FILIAL",
		f."PK",
		"data",
		f."numeroNota")
WHERE
	frete > 0
GROUP BY
	"PK",	
	"FILIAL",
	"data",
	"numeroNota"