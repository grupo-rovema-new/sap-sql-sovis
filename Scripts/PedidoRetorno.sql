-- SBOGRUPOROVEMA.PEDIDORETORNO source

CREATE OR REPLACE VIEW SBOGRUPOROVEMA.PEDIDORETORNO AS
SELECT DISTINCT
	OQUT."DocNum" AS "IDPEDIDORETORNOERP",
	OQUT."U_id_pedido_forca" AS "IDPEDIDOSOVIS",
	"IDEMPRESAERP" AS "IDEMPRESAERP",
	"IDUSUARIOERP" AS "IDUSUARIOERP",
	OQUT."CardCode" AS "IDCLIENTEERP",
	(
	SELECT
		MAX("Usage")
	FROM
		QUT1
	WHERE
		OQUT."DocEntry" = QUT1."DocEntry" )AS "IDTIPOPEDIDOERP",
	OQUT."PeyMethod" AS "IDFORMAPAGTOERP",
	OQUT."GroupNum" AS "IDPRAZOPAGTOERP",
	0 AS "IDTRANSPORTADORAERP",
	'' AS "ORDEMCOMPRA",
	pedido."DocDueDate" AS "DATAENTREGA",
	fatura."DocDate" AS "DATAFATURAMENTO",
	OQUT."Comments" AS "OBSPEDIDO",
	CAST(fatura."Header" AS VARCHAR) AS "OBSNOTA",
	OQUT."DocTotal" AS "VALOR",
	(
	SELECT
		MAX("DiscPrcnt")
	FROM
		QUT1
	WHERE
		OQUT."DocEntry" = QUT1."DocEntry" ) AS "DESCONTO",
	OQUT."DocTotal" AS "VALORTOTAL",
	CASE
		WHEN fatura."DocTotal" IS NULL THEN 0
		ELSE fatura."DocTotal"-(SELECT sum("TotalExpns") FROM INV6 WHERE INV6."DocEntry" = FATURA."DocEntry")
	END AS "VALORTOTALFAT",
	0 AS "SALDOGERADO",
	1 AS "STATUSPEDIDO",
	CAST(CASE
		WHEN OQUT."DocStatus" = 'O' AND ODRF."WddStatus" IS NULL THEN 'Analise Comercial'
		WHEN ODRF."DocEntry" IS NOT NULL AND ODRF."WddStatus" in('W') AND fatura."DocEntry" IS null THEN 'Aguardando aprovação Fin.'
		WHEN pedido."DocStatus" = 'O' THEN 'Pronto Para Faturar'
		WHEN 
			(OQUT."DocStatus" = 'C' AND OQUT.CANCELED = 'Y')
			OR (pedido."DocStatus" = 'C' AND pedido.CANCELED = 'Y')
			THEN 'Cancelado'
		WHEN fatura."DocEntry" IS NOT NULL THEN 'Faturado'
		WHEN ODRF."WddStatus" = 'N' THEN 'Financeiro nao aprovado'
		ELSE 'Status Desconhecido'
		END AS nvarchar )AS "STATUSPEDIDOERP",
	0 AS "FOBCIF",
	0 AS "COEFICIENTE",
	0 AS "PRAZODIGITADO",
	0 AS "VALORST",
	0 AS "VALORTOTALST",
	0 AS "VALORIPI",
	0 AS "VALORTOTALIPI",
	OQUT."DocDate" AS "DATAHORA",
	'R$' AS "IDMOEDAERP",
	0 AS "IDPROPRIEDADEERP",
	-(SELECT sum("TotalExpns") FROM INV6 WHERE INV6."DocEntry" = FATURA."DocEntry") AS "DESCONTOADICIONAL",
	'1' AS "IDPEDIDORETORNOORIGEMERP",
		CAST(CASE
		WHEN OQUT."DocStatus" = 'O' AND ODRF."WddStatus" IS NULL THEN '5'
		WHEN ODRF."DocEntry" IS NOT NULL AND ODRF."WddStatus" in('W') AND fatura."DocEntry" IS null THEN '4'
		WHEN pedido."DocStatus" = 'O' THEN '6'
		WHEN 
			(OQUT."DocStatus" = 'C' AND OQUT.CANCELED = 'Y')
			OR (pedido."DocStatus" = 'C' AND pedido.CANCELED = 'Y')
			THEN '3'
		WHEN fatura."DocEntry" IS NOT NULL THEN '1'
		WHEN ODRF."WddStatus" = 'N' THEN '7' 
		ELSE '8'
		END AS nvarchar ) AS "IDSTATUSWFERP",
	0 AS "INDICERENTABILIDADE",
	fatura."DocEntry" AS faturaId,
	OQUT."U_uuid_forca" AS UUID
FROM
	OQUT
	LEFT JOIN EMPRESA ON "BPLId" = "IDEMPRESAERP"
	LEFT JOIN USUARIO ON "SlpCode" = "IDUSUARIOERP"
	INNER JOIN QUT1   ON OQUT."DocEntry" = QUT1."DocEntry"
	LEFT JOIN ODRF 	  ON OQUT."U_id_pedido_forca" = ODRF."U_id_pedido_forca"
	LEFT JOIN ORDR pedido ON OQUT."U_id_pedido_forca" = pedido."U_id_pedido_forca"
	LEFT JOIN OINV fatura ON OQUT."U_id_pedido_forca" = fatura."U_id_pedido_forca" AND fatura.CANCELED = 'N'
WHERE
	OQUT."U_id_pedido_forca" > '0'

