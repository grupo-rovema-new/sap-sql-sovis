CREATE OR REPLACE VIEW FATURAQTDE AS
SELECT
	YEAR(o."DocDate") AS "Ano",
	CASE 
		WHEN MONTH(o."DocDate") = 1 THEN 'Janeiro'
		WHEN MONTH(o."DocDate") = 2 THEN 'Fevereiro'
        WHEN MONTH(o."DocDate") = 3 THEN 'Março'
        WHEN MONTH(o."DocDate") = 4 THEN 'Abril'
        WHEN MONTH(o."DocDate") = 5 THEN 'Maio'
        WHEN MONTH(o."DocDate") = 6 THEN 'Junho'
        WHEN MONTH(o."DocDate") = 7 THEN 'Julho'
        WHEN MONTH(o."DocDate") = 8 THEN 'Agosto'
        WHEN MONTH(o."DocDate") = 9 THEN 'Setembro'
        WHEN MONTH(o."DocDate") = 10 THEN 'Outubro'
        WHEN MONTH(o."DocDate") = 11 THEN 'Novembro'
        WHEN MONTH(o."DocDate") = 12 THEN 'Dezembro'
	END AS "Mes",
	CASE WEEKDAY(o."DocDate")
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
    END AS "Dia da Semana",
	o."CardCode",
	o."CardName", 
	o."ItemCode",
	o."Dscription",
	CASE WHEN o2."SalUnitMsr" LIKE '%SACA%' THEN o."OutQty" 
			 WHEN o2."SalUnitMsr" LIKE '%QUILO%' THEN ROUND(o."OutQty"/60) ELSE 0 END AS "TotalSC",
	CASE WHEN o2."SalUnitMsr" LIKE '%QUILO%' THEN o."OutQty" 
    		 WHEN o2."SalUnitMsr" LIKE '%SACA%' THEN (o."OutQty" * o2."SWeight1")ELSE 0 END AS "TotalKG",
	o2."SalUnitMsr",
	l.DESCRICAO AS "Linha",
	g.DESCRICAO AS "Grupo",
	a.DESCRICAO AS "Categoria",
	o4."BPLId",
	o5."State1",
	o6."Name" 
FROM
	SBOGRUPOROVEMA.OINM o
LEFT JOIN 
	SBOGRUPOROVEMA.OITM o2 ON
	o."ItemCode" = o2."ItemCode"
LEFT JOIN 
	SBOGRUPOROVEMA.OITB o3 ON
	o2."ItmsGrpCod" = o3."ItmsGrpCod"
LEFT JOIN 
	SBOGRUPOROVEMA.OINV o4 ON
	o."Ref1" = o4."DocNum"
LEFT JOIN 
	SBOGRUPOROVEMA.INV12 i ON 
	o4."DocEntry" = i."DocEntry"
LEFT JOIN 
	SBOGRUPOROVEMA.GRUPOPRODUTO g ON
	o2."U_grupo_sustennutri" = g.IDGRUPOPRODUTOERP
LEFT JOIN 
	SBOGRUPOROVEMA.LINHAPRODUTO l ON
	o2."U_linha_sustennutri" = l.IDLINHAPRODUTOERP
LEFT JOIN 
	SBOGRUPOROVEMA.CATEGORIA a ON 
	o2."U_categoria" = a.IDCATEGORIAERP
LEFT JOIN 
	SBOGRUPOROVEMA.OCRD o5 ON
	O."CardCode" = O5."CardCode"
LEFT JOIN 
	SBOGRUPOROVEMA.OCST o6 ON 
	o5."State1" = o6."Code" 
WHERE
    o."TransType" = 13
    AND o4."BPLId" IN ('2','4','11','17','18')
    AND o4."CANCELED" = 'N'
    AND o."ItemCode" LIKE '%PAC%';