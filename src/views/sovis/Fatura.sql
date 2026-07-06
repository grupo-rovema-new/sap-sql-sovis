-- SBOGRUPOROVEMA.FATURA fonte

CREATE OR REPLACE VIEW FATURA AS
SELECT 
	"DocNum" AS "IDFATURAERP",
	"CardCode" AS "IDCLIENTEERP",
	"Serial" AS "NUMNF",
	"SeriesStr" AS "SERIE" ,
	(SELECT SUM("PriceBefDi"*"Quantity") FROM INV1 WHERE "DocEntry"= N."DocEntry" )AS "VALORPRODUTOS", --ALTERADO O SOMA DE SUM(LINETOTAL) PARA SUM(INV1.PriceBefDi*INV1.Quantity) *25/03/2024
	n."NfeValue"-n."DiscSum" AS "VALORNOTA", --Adicionado o campo DiscSum para subtrair o desconto em notas de entrega futura 19/05/2026
	0 AS "COMISSAO",
	p."GrsWeight" AS "PESOBRUTO",
	p."NetWeight" AS "PESOLIQUIDO",
	"TaxDate" AS  "DATAEMISSAO",
	"DocDate" AS "DATASAIDA",
	0 AS "HORASAIDA",
	1 AS "SITUACAO" ,
	1 AS "IDPEDIDO",
	u."IDUSUARIOERP" AS "IDUSUARIOERP",
	0 AS "IDSUPERVIERP",
	(SELECT MAX("Usage") FROM INV1 WHERE "DocEntry" = N."DocEntry" AND "Usage" IN (SELECT t."IDTIPOPEDIDOERP" FROM TIPOPEDIDO t WHERE t."SITUACAO" = 1)) AS "IDTIPOPEDIDOERP", --Alterado o conjunto de dados do operador IN do campo USAGE DE 9,16, para SELECT t."IDTIPOPEDIDOERP" FROM TIPOPEDIDO t WHERE t."SITUACAO" = 1 *25/03/2024 
	"GroupNum" AS "IDPRAZOPAGTOERP ",
	CASE ltrim(rtrim(n."PeyMethod"))
		WHEN '' THEN 'AVISTA'
		ELSE IFNULL(n."PeyMethod",'AVISTA')
	END AS "IDFORMAPAGTOERP",
	"BPLId" AS "IDEMPRESAERP",
	t5."DocEntry" 
FROM OINV N
	INNER JOIN INV12 P ON N."DocEntry" = p."DocEntry"
	LEFT JOIN OSLP O ON n."SlpCode" = o."SlpCode"
	INNER JOIN USUARIO u ON n."SlpCode" = u.IDUSUARIOERP
	left JOIN RIN21 T5 ON n."DocNum" = T5."RefDocNum"
WHERE N.CANCELED = 'N' --Trazer só notas não canceldas
	AND N."Model" IN ('39','54') --Adicionado o modelo 54 NFC-e para se visualizado *25/03/2024
	AND n."DocEntry" IN (SELECT "DocEntry" FROM INV1 WHERE "Usage" IN (SELECT t."IDTIPOPEDIDOERP" FROM TIPOPEDIDO t WHERE t."SITUACAO" = 1) AND "ItemCode" LIKE '%PAC%')--Alterado o conjunto de dados do operador IN do campo USAGE DE 9,16, para SELECT t."IDTIPOPEDIDOERP" FROM TIPOPEDIDO t WHERE t."SITUACAO" = 1 *25/03/2024
	AND n."BPLId" IN (SELECT e."IDEMPRESAERP" FROM EMPRESA e)
	AND t5."DocEntry" IS NULL;