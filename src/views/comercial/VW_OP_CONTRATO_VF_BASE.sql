CREATE OR REPLACE VIEW VW_OP_CONTRATO_VF_BASE AS
SELECT
    acf."DocEntry"                              AS "ChaveOperacao",
    acf."DocEntry"                              AS "NumeroContrato",
    acf."U_orderDocEntry"                       AS "PedidoOriginal",
    acf."U_cardCode"                            AS "CardCode",
    acf."U_cardName"                            AS "CardName",
    acf."U_dataCriacao"                         AS "DataOperacao",
    acf."U_valorFrete"                          AS "FreteContrato",
    acf."U_valorProdutos"                       AS "ValorProdutos",
    acf."U_status"                              AS "StatusOperacao",
    acf."U_valorProdutos" + acf."U_valorFrete"  AS "ValorOperacao",
    acf."U_vendedor"                            AS "SlpCode",
    V."SlpName"                                 AS "Vendedor",
    acf."U_filial"                              AS "BPLId",
    F."BPLName"                                 AS "Filial"
FROM "@AR_CONTRATO_FUTURO" acf
LEFT JOIN OSLP V ON V."SlpCode" = acf."U_vendedor"
LEFT JOIN OBPL F ON F."BPLId"   = acf."U_filial";