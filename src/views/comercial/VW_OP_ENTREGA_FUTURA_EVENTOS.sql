CREATE OR REPLACE VIEW VW_OP_ENTREGA_FUTURA_EVENTOS AS
SELECT * FROM (

    /* --- NOTA MAE (ancora) -------------------------------------------------- */
    SELECT DISTINCT
        2                                        AS "TipoOperacao",
        'ENTREGA FUTURA'                         AS "DescOperacao",
        T0."DocEntry"                            AS "ChaveOperacao",
        T0."CardCode", T0."CardName",
        T0."SlpCode",
        T4."SlpName"                             AS "Vendedor",
        T0."BPLId",
        T0."BPLName"                             AS "Filial",
        T0."DocDate"                             AS "DataOperacao",
        T0."DocTotal"                            AS "ValorOperacao",
        T0."DocStatus"                           AS "StatusOperacao",
        'NOTA MAE'                               AS "TipoLinha",
        0                                        AS "OrdemLinha",
        T0."DocNum"                              AS "NumeroDocumento",
        T0."DocEntry"                            AS "DocEntryDocumento",
        T0."DocDate"                             AS "DataLancamento",
        T0."DocDueDate"                          AS "DataVencimento",
        T0."DocTotal"                            AS "ValorDocumento",
        T0."DocStatus"                           AS "StatusDocumento",
        CASE WHEN T0."Serial" IS NOT NULL AND T0."Serial" <> 0
             THEN CAST(T0."Serial" AS NVARCHAR(20))
             ELSE CAST(T0."DocNum" AS NVARCHAR(20)) END
                                                 AS "NumeroNota",
        T0."ExepAmnt"                            AS "Frete",
        IFNULL(T0."DpmAppl", 0)                  AS "DpmAppl",
        'Nao'                                    AS "Situacao",
        CASE WHEN T0."DocStatus" = 'C' THEN 'Fechado'
             WHEN T0."DocStatus" = 'O' THEN 'Aberto'
             ELSE 'Indefinido' END               AS "SituacaoDetalhe"
    FROM OINV  T0
    INNER JOIN INV1 T1 ON T1."DocEntry" = T0."DocEntry"
    INNER JOIN OSLP T4 ON T4."SlpCode"  = T0."SlpCode"
    WHERE T0."CANCELED" = 'N'
      AND T0."isIns" = 'Y'
      AND T1."Usage" = 16
      AND T0."U_venda_futura" IS NULL
      AND T0."U_Rov_Refaturamento" = 'NAO'

    UNION ALL

    /* --- PAGAMENTOS DA MAE (ORCT via RCT2, InvType 13) ---------------------- */
    SELECT
        2, 'ENTREGA FUTURA', T0."DocEntry",
        T0."CardCode", T0."CardName",
        T0."SlpCode", T4."SlpName",
        T0."BPLId", T0."BPLName",
        T0."DocDate", T0."DocTotal", T0."DocStatus",
        'PAGAMENTO', 1,
        p."DocNum", p."DocEntry", p."DocDate", p."DocDueDate",
        r2."SumApplied",
        CASE WHEN p."Canceled" = 'Y' THEN 'C' ELSE 'O' END,
        CAST(p."DocNum" AS NVARCHAR(20)),
        CAST(NULL AS DECIMAL(19,2)),
        CAST(NULL AS DECIMAL(19,2)),
        CASE WHEN p."Canceled" = 'Y' THEN 'Sim' ELSE 'Nao' END,
        CASE WHEN p."Canceled" = 'Y' THEN 'Cancelado' ELSE 'Recebido' END
    FROM OINV  T0
    INNER JOIN OSLP T4 ON T4."SlpCode"  = T0."SlpCode"
    INNER JOIN RCT2 r2 ON r2."DocEntry" = T0."DocEntry"
                      AND r2."InvType"  = 13
    INNER JOIN ORCT p  ON p."DocEntry"  = r2."DocNum"
    /* mesmo vinculo corrigido da op.1: RCT2."DocNum" -> ORCT."DocEntry"     */
    WHERE T0."CANCELED" = 'N'
      AND T0."isIns" = 'Y'
      AND T0."U_venda_futura" IS NULL
      AND T0."U_Rov_Refaturamento" = 'NAO'
      AND EXISTS (SELECT 1 FROM INV1 x
                  WHERE x."DocEntry" = T0."DocEntry" AND x."Usage" = 16)

    UNION ALL

    /* --- ENTREGAS FILHAS (ODLN usage 17, doc-base = NF mae) ----------------- */
    /* DLN1.BaseEntry -> OINV (BaseType 13): filha criada a partir da mae.
       Uma mae pode ter varias filhas (entregas parciais).                     */
    SELECT DISTINCT
        2, 'ENTREGA FUTURA', T0."DocEntry",
        T0."CardCode", T0."CardName",
        T0."SlpCode", T4."SlpName",
        T0."BPLId", T0."BPLName",
        T0."DocDate", T0."DocTotal", T0."DocStatus",
        'ENTREGA', 2,
        d."DocNum", d."DocEntry", d."DocDate", d."DocDueDate",
        d."DocTotal", d."DocStatus",
        CASE WHEN d."Serial" IS NOT NULL AND d."Serial" <> 0
             THEN CAST(d."Serial" AS NVARCHAR(20))
             ELSE CAST(d."DocNum" AS NVARCHAR(20)) END,
        d."ExepAmnt",
        CAST(NULL AS DECIMAL(19,2)),
        CASE WHEN d."CANCELED" = 'Y' THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN d."CANCELED"  = 'Y' THEN 'Cancelado'
            WHEN d."DocStatus" = 'C' THEN 'Fechado'
            WHEN d."DocStatus" = 'O' THEN 'Aberto'
            ELSE 'Indefinido'
        END
    FROM OINV  T0
    INNER JOIN OSLP T4 ON T4."SlpCode"   = T0."SlpCode"
    INNER JOIN DLN1 dl ON dl."BaseEntry" = T0."DocEntry"
                      AND dl."BaseType"  = 13
                      AND dl."Usage"     = 17
    INNER JOIN ODLN d  ON d."DocEntry"   = dl."DocEntry"
    WHERE T0."CANCELED" = 'N'
      AND T0."isIns" = 'Y'
      AND T0."U_venda_futura" IS NULL
      AND T0."U_Rov_Refaturamento" = 'NAO'
      AND EXISTS (SELECT 1 FROM INV1 x
                  WHERE x."DocEntry" = T0."DocEntry" AND x."Usage" = 16)

    UNION ALL

    /* --- DEVOLUCOES DA MAE (ORIN via doc-base RIN1, BaseType 13) ------------ */
    SELECT DISTINCT
        2, 'ENTREGA FUTURA', T0."DocEntry",
        T0."CardCode", T0."CardName",
        T0."SlpCode", T4."SlpName",
        T0."BPLId", T0."BPLName",
        T0."DocDate", T0."DocTotal", T0."DocStatus",
        'DEVOLUCAO', 3,
        r."DocNum", r."DocEntry", r."DocDate", r."DocDueDate",
        r."DocTotal", r."DocStatus",
        CASE WHEN r."Serial" IS NOT NULL AND r."Serial" <> 0
             THEN CAST(r."Serial" AS NVARCHAR(20))
             ELSE CAST(r."DocNum" AS NVARCHAR(20)) END,
        r."ExepAmnt",
        CAST(NULL AS DECIMAL(19,2)),
        CASE WHEN r."CANCELED" = 'Y' THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN r."CANCELED"  = 'Y' THEN 'Cancelado'
            WHEN r."DocStatus" = 'C' THEN 'Fechado'
            WHEN r."DocStatus" = 'O' THEN 'Aberto'
            ELSE 'Indefinido'
        END
    FROM OINV  T0
    INNER JOIN OSLP T4 ON T4."SlpCode"   = T0."SlpCode"
    INNER JOIN RIN1 rl ON rl."BaseEntry" = T0."DocEntry"
                      AND rl."BaseType"  = 13
    INNER JOIN ORIN r  ON r."DocEntry"   = rl."DocEntry"
    WHERE T0."CANCELED" = 'N'
      AND T0."isIns" = 'Y'
      AND T0."U_venda_futura" IS NULL
      AND T0."U_Rov_Refaturamento" = 'NAO'
      AND EXISTS (SELECT 1 FROM INV1 x
                  WHERE x."DocEntry" = T0."DocEntry" AND x."Usage" = 16)
);
