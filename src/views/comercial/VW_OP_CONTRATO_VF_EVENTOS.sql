CREATE OR REPLACE VIEW VW_OP_CONTRATO_VF_EVENTOS AS
SELECT * FROM (
 
    /* --- CONTRATO (ancora) -------------------------------------------------- */
    SELECT
        3                                        AS "TipoOperacao",
        'CONTRATO VENDA FUTURA'                  AS "DescOperacao",
        c."ChaveOperacao",
        c."CardCode", c."CardName", c."SlpCode", c."Vendedor",
        c."BPLId", c."Filial",
        c."DataOperacao", c."ValorOperacao", c."StatusOperacao",
        'CONTRATO'                               AS "TipoLinha",
        0                                        AS "OrdemLinha",
        c."NumeroContrato"                       AS "NumeroDocumento",
        c."NumeroContrato"                       AS "DocEntryDocumento",
        c."DataOperacao"                         AS "DataLancamento",
        CAST(NULL AS DATE)                       AS "DataVencimento",
        c."ValorOperacao"                        AS "ValorDocumento",
        c."StatusOperacao"                       AS "StatusDocumento",
        CAST(c."NumeroContrato" AS NVARCHAR(20)) AS "NumeroNota",
        c."FreteContrato"                        AS "Frete",
        CAST(NULL AS DECIMAL(19,2))              AS "DpmAppl",
        ''                                       AS "Situacao",
        c."StatusOperacao"                       AS "SituacaoDetalhe",
        c."CondPagCodigo"                        AS "CondPagCodigo",
        c."CondPagDescricao"                     AS "CondPagDescricao",
        c."FormaPagCodigo"                       AS "FormaPagCodigo",
        c."FormaPagDescricao"                    AS "FormaPagDescricao",
        c."StatusPagamentoContrato"               AS "StatusPagamento",
        CAST(NULL AS DECIMAL(19,2))               AS "ValorAdiantamentoNota",
        CAST(NULL AS DECIMAL(19,2))               AS "ValorDocumentoOriginal"
    FROM VW_OP_CONTRATO_VF_BASE c

    UNION ALL

    /* --- ADIANTAMENTOS (ODPI) ----------------------------------------------- */
    SELECT
        3, 'CONTRATO VENDA FUTURA', c."ChaveOperacao",
        c."CardCode", c."CardName", c."SlpCode", c."Vendedor",
        c."BPLId", c."Filial",
        c."DataOperacao", c."ValorOperacao", c."StatusOperacao",
        'ADIANTAMENTO', 1,
        o."DocNum", o."DocEntry", o."DocDate", o."DocDueDate",
        o."DocTotal", o."DocStatus",
        CAST(o."DocNum" AS NVARCHAR(20)),
        CAST(NULL AS DECIMAL(19,2)),
        IFNULL(o."DpmAppl", 0),
        CASE WHEN o."CANCELED" <> 'N'
               OR EXISTS (
                    SELECT 1 FROM RIN1 rl
                    INNER JOIN ORIN r2 ON r2."DocEntry" = rl."DocEntry"
                    WHERE rl."BaseEntry" = o."DocEntry"
                      AND rl."BaseType"  = 203
                      AND r2."CANCELED"  = 'N'
                  )
             THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN o."CANCELED" <> 'N'  THEN 'Cancelado'
            WHEN EXISTS (
                    SELECT 1 FROM RIN1 rl
                    INNER JOIN ORIN r2 ON r2."DocEntry" = rl."DocEntry"
                    WHERE rl."BaseEntry" = o."DocEntry"
                      AND rl."BaseType"  = 203
                      AND r2."CANCELED"  = 'N'
                 )
                THEN 'Devolvido'
            WHEN o."DocStatus" = 'C' THEN 'Pago'
            WHEN o."DocStatus" = 'O' THEN 'Nao pago'
            ELSE 'Indefinido'
        END,
        CAST(NULL AS INTEGER), CAST(NULL AS NVARCHAR(50)),
        CAST(NULL AS NVARCHAR(10)), CAST(NULL AS NVARCHAR(50)),
        CAST(NULL AS NVARCHAR(20)),
        CAST(NULL AS DECIMAL(19,2)),
        CAST(NULL AS DECIMAL(19,2))
    FROM VW_OP_CONTRATO_VF_BASE c
    INNER JOIN ODPI o ON o."U_venda_futura" = c."ChaveOperacao"
 
    UNION ALL
 
    /* --- ENTREGAS (OINV usage 9 com U_venda_futura = contrato) --------------- */
    SELECT DISTINCT
        3, 'CONTRATO VENDA FUTURA', c."ChaveOperacao",
        c."CardCode", c."CardName", c."SlpCode", c."Vendedor",
        c."BPLId", c."Filial",
        c."DataOperacao", c."ValorOperacao", c."StatusOperacao",
        'ENTREGA', 2,
        i."DocNum", i."DocEntry", i."DocDate", i."DocDueDate",
        i."DocTotal", i."DocStatus",
        CASE WHEN i."Serial" IS NOT NULL AND i."Serial" <> 0
             THEN CAST(i."Serial" AS NVARCHAR(20))
             ELSE CAST(i."DocNum" AS NVARCHAR(20)) END,
        i."ExepAmnt",
        IFNULL(i."DpmAppl", 0),   -- adiantamento abatido na entrega
        CASE WHEN i."CANCELED" <> 'N' THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN i."CANCELED"  = 'Y' THEN 'Cancelado'
            WHEN i."DocStatus" = 'C' THEN 'Fechado'
            WHEN i."DocStatus" = 'O' THEN 'Aberto'
            ELSE 'Indefinido'
        END,
        i."GroupNum"                             AS "CondPagCodigo",
        PC."PymntGroup"                          AS "CondPagDescricao",
        i."PeyMethod"                            AS "FormaPagCodigo",
        PM."Descript"                             AS "FormaPagDescricao",
        CASE
            WHEN IFNULL(i."PaidToDate",0) >= i."DocTotal"
                THEN 'Pago'
            WHEN IFNULL(i."PaidToDate",0) > 0
                 AND i."PaidToDate" < i."DocTotal"
                THEN 'Pago Parcial'
            WHEN IFNULL(i."PaidToDate",0) = 0
                 AND i."DocDueDate" < CURRENT_DATE
                THEN 'Vencido'
            ELSE 'Nao Pago'
        END                                      AS "StatusPagamento",
        i."DpmAmnt"                               AS "ValorAdiantamentoNota",
        i."DocTotal" + IFNULL(i."DpmAmnt",0)      AS "ValorDocumentoOriginal"
        -- NOTA: aqui e' o adiantamento NATIVO aplicado nesta entrega
        -- especifica (nao confundir com o adiantamento do CONTRATO via ODPI,
        -- que fica na linha ADIANTAMENTO acima). Um contrato pode ter varias
        -- ENTREGAs, cada uma com seu proprio DpmAmnt - por isso NAO e
        -- constante da operacao aqui, diferente de op.1/op.2.
    FROM VW_OP_CONTRATO_VF_BASE c
    INNER JOIN OINV i  ON i."U_venda_futura" = c."ChaveOperacao"
    INNER JOIN INV1 l1 ON l1."DocEntry" = i."DocEntry"
    LEFT  JOIN OCTG PC ON PC."GroupNum" = i."GroupNum"
    LEFT  JOIN OPYM PM ON PM."PayMethCod"  = i."PeyMethod"
    WHERE i."isIns" = 'N'
      AND l1."Usage" = 9           -- filha do contrato sai como venda normal
 
    UNION ALL
 
    /* --- DEVOLUCOES (ORIN, exceto estorno de adiantamento SeqCode = 1) ------- */
    SELECT
        3, 'CONTRATO VENDA FUTURA', c."ChaveOperacao",
        c."CardCode", c."CardName", c."SlpCode", c."Vendedor",
        c."BPLId", c."Filial",
        c."DataOperacao", c."ValorOperacao", c."StatusOperacao",
        'DEVOLUCAO', 3,
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
        CAST(NULL AS DECIMAL(19,2)),
        CAST(NULL AS DECIMAL(19,2))
    FROM VW_OP_CONTRATO_VF_BASE c
    INNER JOIN ORIN r ON r."U_venda_futura" = c."ChaveOperacao"
                     AND IFNULL(r."SeqCode", 0) <> 1
);
 
