CREATE OR REPLACE VIEW VW_OP_VENDA_NORMAL_EVENTOS AS
SELECT * FROM (
 
    /* --- NOTA (ancora) ---------------------------------------------------- */
    SELECT DISTINCT
        1                                        AS "TipoOperacao",
        'VENDA NORMAL'                           AS "DescOperacao",
        T0."DocEntry"                            AS "ChaveOperacao",
        T0."CardCode", T0."CardName",
        T0."SlpCode",
        T4."SlpName"                             AS "Vendedor",
        T0."BPLId",
        T0."BPLName"                             AS "Filial",
        T0."DocDate"                             AS "DataOperacao",
        T0."DocTotal"                            AS "ValorOperacao",
        T0."DocStatus"                           AS "StatusOperacao",
        'NOTA'                                   AS "TipoLinha",
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
        CAST(NULL AS DECIMAL(19,2))              AS "Frete",
        CAST(NULL AS DECIMAL(19,2))              AS "DpmAppl",
        'Nao'                                    AS "Situacao",
        CASE WHEN T0."DocStatus" = 'C' THEN 'Fechado'
             WHEN T0."DocStatus" = 'O' THEN 'Aberto'
             ELSE 'Indefinido' END               AS "SituacaoDetalhe",
        T0."GroupNum"                            AS "CondPagCodigo",
        PC."PymntGroup"                          AS "CondPagDescricao",
        T0."PeyMethod"                           AS "FormaPagCodigo",
        PM."Descript"                             AS "FormaPagDescricao",
        CASE
            WHEN IFNULL(T0."PaidToDate",0) >= T0."DocTotal"
                THEN 'Pago'
            WHEN IFNULL(T0."PaidToDate",0) > 0
                 AND T0."PaidToDate" < T0."DocTotal"
                THEN 'Pago Parcial'
            WHEN IFNULL(T0."PaidToDate",0) = 0
                 AND T0."DocDueDate" < CURRENT_DATE
                THEN 'Vencido'
            ELSE 'Nao Pago'
        END                                      AS "StatusPagamento",
        T0."DpmAmnt"                              AS "ValorAdiantamentoNota",
        T0."DocTotal" + IFNULL(T0."DpmAmnt",0)    AS "ValorDocumentoOriginal"
    FROM OINV  T0
    INNER JOIN INV1 T1 ON T1."DocEntry" = T0."DocEntry"
    INNER JOIN OSLP T4 ON T4."SlpCode"  = T0."SlpCode"
    LEFT  JOIN OCTG PC ON PC."GroupNum" = T0."GroupNum"
    LEFT  JOIN OPYM PM ON PM."PayMethCod"   = T0."PeyMethod"
    WHERE T0."CANCELED" = 'N'
      AND T1."Usage" = 9
      AND T0."isIns" = 'N'
      AND T0."U_venda_futura" IS NULL
      AND T0."U_Rov_Refaturamento" = 'NAO'
 
    UNION ALL
 
    /* --- PAGAMENTOS (ORCT via RCT2, InvType 13) ---------------------------- */
    SELECT
        1, 'VENDA NORMAL', T0."DocEntry",
        T0."CardCode", T0."CardName",
        T0."SlpCode", T4."SlpName",
        T0."BPLId", T0."BPLName",
        T0."DocDate", T0."DocTotal", T0."DocStatus",
        'PAGAMENTO', 1,
        p."DocNum", p."DocEntry", p."DocDate", p."DocDueDate",
        r2."SumApplied",
        CASE WHEN p."Canceled" <> 'N' THEN 'C' ELSE 'O' END,
        CAST(p."DocNum" AS NVARCHAR(20)),
        CAST(NULL AS DECIMAL(19,2)),
        CAST(NULL AS DECIMAL(19,2)),
        CASE WHEN p."Canceled" <> 'N' THEN 'Sim' ELSE 'Nao' END,
        CASE WHEN p."Canceled" <> 'N' THEN 'Cancelado' ELSE 'Recebido' END,
        CAST(NULL AS INTEGER),        -- CondPagCodigo (nao se aplica)
        CAST(NULL AS NVARCHAR(50)),   -- CondPagDescricao
        CAST(NULL AS NVARCHAR(10)),   -- FormaPagCodigo
        CAST(NULL AS NVARCHAR(50)),   -- FormaPagDescricao
        CAST(NULL AS NVARCHAR(20)),   -- StatusPagamento
        T0."DpmAmnt",                 -- ValorAdiantamentoNota (repete o valor da nota)
        T0."DocTotal" + IFNULL(T0."DpmAmnt",0)   -- ValorDocumentoOriginal
    FROM OINV  T0
    INNER JOIN OSLP T4 ON T4."SlpCode"  = T0."SlpCode"
    INNER JOIN RCT2 r2 ON r2."DocEntry" = T0."DocEntry"
                      AND r2."InvType"  = 13
    INNER JOIN ORCT p  ON p."DocEntry"  = r2."DocNum"
    /* RCT2."DocNum" armazena o DocEntry do pagamento (ORCT), nao o DocNum -
       confirmado no diagnostico D2/D3: numeracoes em faixas distintas.      */
    WHERE T0."CANCELED" = 'N'
      AND T0."isIns" = 'N'
      AND T0."U_venda_futura" IS NULL
      AND T0."U_Rov_Refaturamento" = 'NAO'
      AND EXISTS (SELECT 1 FROM INV1 x
                  WHERE x."DocEntry" = T0."DocEntry" AND x."Usage" = 9)
 
    UNION ALL
 
    /* --- DEVOLUCOES (ORIN via doc-base RIN1, BaseType 13) ------------------ */
    SELECT DISTINCT
        1, 'VENDA NORMAL', T0."DocEntry",
        T0."CardCode", T0."CardName",
        T0."SlpCode", T4."SlpName",
        T0."BPLId", T0."BPLName",
        T0."DocDate", T0."DocTotal", T0."DocStatus",
        'DEVOLUCAO', 2,
        r."DocNum", r."DocEntry", r."DocDate", r."DocDueDate",
        r."DocTotal", r."DocStatus",
        CASE WHEN r."Serial" IS NOT NULL AND r."Serial" <> 0
             THEN CAST(r."Serial" AS NVARCHAR(20))
             ELSE CAST(r."DocNum" AS NVARCHAR(20)) END,
        r."ExepAmnt",
        CAST(NULL AS DECIMAL(19,2)),
        CASE WHEN r."CANCELED" <> 'N' THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN r."CANCELED"  = 'Y' THEN 'Cancelado'
            WHEN r."DocStatus" = 'C' THEN 'Fechado'
            WHEN r."DocStatus" = 'O' THEN 'Aberto'
            ELSE 'Indefinido'
        END,
        CAST(NULL AS INTEGER), CAST(NULL AS NVARCHAR(50)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(50)),
        CAST(NULL AS NVARCHAR(20)),
        T0."DpmAmnt",
        T0."DocTotal" + IFNULL(T0."DpmAmnt",0)
    FROM OINV  T0
    INNER JOIN OSLP T4 ON T4."SlpCode"   = T0."SlpCode"
    INNER JOIN RIN1 rl ON rl."BaseEntry" = T0."DocEntry"
                      AND rl."BaseType"  = 13
    INNER JOIN ORIN r  ON r."DocEntry"   = rl."DocEntry"
    WHERE T0."CANCELED" = 'N'
      AND T0."isIns" = 'N'
      AND T0."U_venda_futura" IS NULL
      AND T0."U_Rov_Refaturamento" = 'NAO'
      AND EXISTS (SELECT 1 FROM INV1 x
                  WHERE x."DocEntry" = T0."DocEntry" AND x."Usage" = 9)
);
 
