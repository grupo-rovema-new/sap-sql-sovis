CREATE OR REPLACE VIEW NotasComCFOpErrado AS
	SELECT
		PK,
		"numeroNota",
		"data",
		"CardCode",
		"CardName",
		FILIAL
	FROM
		FaturamentoAndrew
	WHERE 
		FILIAL NOT IN ('SUSTENNUTRI NUTRICAO ANIMAL LTDA - Matriz')
		AND	CFOP in(5101,6101)
	GROUP BY
		PK,
		"numeroNota",
		"data",
		"CardCode",
		"CardName",
		FILIAL