CREATE OR REPLACE VIEW ASSTABPRECOPRODUTO AS 
SELECT
		ITM1."PriceList"  AS "IDTABPRECOERP",
		ITM1."ItemCode"  AS IDPRODUTOERP,
		"Price" AS "VALOR1",
		0.00 AS "VALOR2",
		0.00 AS "VALOR3",
		0.00 AS "VALOR4",
		0.00 AS "VALOR5",
		0.00 AS "VALOR6",
		0.00 AS "VALOR7",
		"Price" AS "VALORMAXIMO",
		"Price" AS "VALORMINIMO",
		0.00 AS "VALORUNITARIO",
		12 AS "DESCMAXIMO1" ,
		0 AS "DESCMAXIMO2",
		0 AS "DESCMAXIMO3",
		0 AS "DESCMAXIMO4" ,
		0 AS "DESCMAXIMO5",
		0 AS "DESCMAXIMO6" ,
		0 AS "DESCMAXIMO7" ,
		0.00 AS "ICMS",
	    1 AS "LIBERAALTERACAO",
		0.00 AS "CUSTOPRODUTO",
		0.00 AS "MARGEMITEM",
		0 AS "OFERTA" ,
		0 AS "PMC" ,
		0 AS "ENCARGO",
		0 AS "ASSTABPRECOPRODUTO.COMISSAO",
        0 AS "VALORFABRICA",
        0 AS"DESCFLEXVLRMENOR",
        0 AS "IGNORAREGRAPRAZO",
        0 AS "PERMITETROCA" ,
        0 AS "PERMITEBONIFICACAO",
        1 AS "QTDEMINIMAVENDA",
        '' AS "TARJAITEMCATALOGO",
        0 AS"PERMITEBONIFNAVENDA",
        '' AS "DATAMAXIMA",
        0 AS "PERCENTUALDIARIO",
        0 AS "PERCENTUALDIARIOJURO",
        0 AS "ACRESFLEXVLRMAIOR",
        0 AS "PERCFLEXSOMA",
        0 AS "MINIMOPRODUTOQTDE",
        0 AS "MAXIMOPRODUTOQTDE",
        0 AS "ASSTABPRECOPRODUTO.DESCPRODUTOQTDE",
        0 AS "ASSTABPRECOPRODUTO.DESCTRIPLOMAXIMO1",
        0 AS "ASSTABPRECOPRODUTO.DESCTRIPLOMAXIMO2",
        0 AS "ASSTABPRECOPRODUTO.DESCTRIPLOMAXIMO3",
        0 AS "IDGRUPOCOMISSAOER",
        0 AS "PERCENTUALMARGEMMINIMA"
	
	
	FROM
		ITM1
	WHERE
		"PriceList" IN (SELECT IDTABPRECOERP FROM TABPRECO t)
		AND "ItemCode" in(SELECT IDPRODUTOERP FROM produto)
		AND "Price" > 0
		AND "ItemCode"  IN (SELECT T0."ItemCode" FROM OITM T0 WHERE T0."validFor"  = 'Y') 
		

