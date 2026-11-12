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
    /* valor bruto do pedido de origem (DocTotal + adiantamento nativo).
       E a regua que o relatorio de faturamento usa para o contrato, por
       isso fica exposta ao lado do valor do proprio contrato.          */
    ped."DocTotal" + IFNULL(ped."DpmAmnt", 0)   AS "ValorPedidoOriginal",
    acf."U_vendedor"                            AS "SlpCode",
    V."SlpName"                                 AS "Vendedor",
    acf."U_filial"                              AS "BPLId",
    F."BPLName"                                 AS "Filial",
    ped."GroupNum"                              AS "CondPagCodigo",
    PC."PymntGroup"                             AS "CondPagDescricao",
    ped."PeyMethod"                             AS "FormaPagCodigo",
    PM."Descript"                                AS "FormaPagDescricao",
    CASE
        WHEN IFNULL(adto."TemPendente", 0) = 0 THEN 'Pago'
        WHEN adto."TemVencido" = 1             THEN 'Vencido'
        ELSE 'Nao Pago'
    END                                          AS "StatusPagamentoContrato",
    /* contrato com devolucao vinculada (ORIN do contrato, fora o estorno
       de adiantamento SeqCode = 1). Nas op.1 e op.2 o mesmo flag sai da
       RIN21, pela referencia fiscal - a regra e outra aqui porque o
       contrato nao tem DocNum de nota para a RIN21 referenciar.        */
    CASE WHEN EXISTS (
                SELECT 1 FROM ORIN r
                WHERE r."U_venda_futura" = acf."DocEntry"
                  AND IFNULL(r."SeqCode", 0) <> 1
                  AND r."CANCELED" = 'N')
         THEN 'Sim' ELSE 'Nao' END                 AS "TemDevolucao"
FROM "@AR_CONTRATO_FUTURO" acf
LEFT JOIN OSLP V   ON V."SlpCode"    = acf."U_vendedor"
LEFT JOIN OBPL F   ON F."BPLId"      = acf."U_filial"
LEFT JOIN ORDR ped ON ped."DocEntry" = acf."U_orderDocEntry"
LEFT JOIN OCTG PC  ON PC."GroupNum"  = ped."GroupNum"
LEFT JOIN OPYM PM  ON PM."PayMethCod" = ped."PeyMethod"
LEFT JOIN (
    /* Por contrato, verifica se existe adiantamento (ODPI) que NAO esta
       genuinamente pago-e-retido. "Genuinamente pago" = fechado (C),
       nao cancelado, E sem nenhuma devolucao vinculada (ORIN via RIN1
       BaseType=203, apontando pro proprio ODPI) - devolucao de
       adiantamento fecha o documento mas o dinheiro voltou, entao NAO
       conta como pago (mesmo efeito pratico de um cancelamento).      */
    SELECT
        o."U_venda_futura" AS "Contrato",
        MAX(CASE WHEN NOT (
                o."DocStatus" = 'C'
                AND NOT EXISTS (
                      SELECT 1 FROM RIN1 rl
                      INNER JOIN ORIN r2 ON r2."DocEntry" = rl."DocEntry"
                      WHERE rl."BaseEntry" = o."DocEntry"
                        AND rl."BaseType"  = 203
                        AND r2."CANCELED"  = 'N'
                )
            ) THEN 1 ELSE 0 END)                AS "TemPendente",
        MAX(CASE WHEN NOT (
                o."DocStatus" = 'C'
                AND NOT EXISTS (
                      SELECT 1 FROM RIN1 rl
                      INNER JOIN ORIN r2 ON r2."DocEntry" = rl."DocEntry"
                      WHERE rl."BaseEntry" = o."DocEntry"
                        AND rl."BaseType"  = 203
                        AND r2."CANCELED"  = 'N'
                )
            ) AND o."DocDueDate" < CURRENT_DATE
            THEN 1 ELSE 0 END)                  AS "TemVencido"
    FROM ODPI o
    WHERE o."CANCELED" = 'N'
    GROUP BY o."U_venda_futura"
) adto ON adto."Contrato" = acf."DocEntry";