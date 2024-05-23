  CREATE OR REPLACE VIEW ASSTABPRECOPRODUTO_VA AS
SELECT
		ITM1."PriceList" || ' - ' || ITM1."ItemCode" AS "IDASSTABPRECOPRODUTOERP",
		ITM1."PriceList"  AS "IDTABPRECOERP",
		ITM1."ItemCode"  AS "IDPRODUTOERP",
		"Price" AS "VALOR",
		"Price"-((c."U_desconto"/100)*"Price") AS "VALORMINIMO", --formula que calcula o valor minino de desconto, usando o campo U_desconto
		c."U_desconto" AS "DESCONTOMAXIMO"
	FROM
		ITM1
		LEFT JOIN OPLN p on(p."ListNum" = ITM1."PriceList")
		LEFT JOIN "@COMISSAO" c on(c."Code" = p."U_tipoComissao")
	WHERE
		"PriceList" IN (SELECT IDTABPRECOERP FROM TABPRECO t)
		AND "ItemCode" in(SELECT IDPRODUTOERP FROM produto)
		AND "Price" > 0
		AND "ItemCode"  IN (SELECT T0."ItemCode" FROM OITM T0 WHERE T0."validFor"  = 'Y');  
  