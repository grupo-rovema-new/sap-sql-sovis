

CREATE OR REPLACE VIEW GGF AS
(((SELECT
    "BPLId",
    pai,
    "valor" AS apurado,
    0 AS realizado,
    0 AS estoque,
    mes,
    ano,
    "ano-mes"
FROM
	ggfApurado AS apurado) UNION (SELECT
    "BPLId",
    pai,
    0 AS apurado,
    "valor" AS realizado,
    0 AS estoque,
    mes,
    ano,
    "ano-mes"
FROM
	ggfApropriado AS apropriado)) UNION (SELECT
    "BPLId",
    nome,
    0 AS apurado,
    0 AS realizado,
    valor AS estoque,
    mes,
    ano,
    "ano-mes"
FROM
	ggfProduzido AS produzido));