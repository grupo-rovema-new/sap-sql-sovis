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
        c."StatusOperacao"                       AS "SituacaoDetalhe"
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
        CASE WHEN o."CANCELED" = 'Y' THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN o."DocStatus" = 'C' AND o."CANCELED" = 'Y' THEN 'Cancelado'
            WHEN o."DocStatus" = 'C' AND o."CANCELED" = 'N' THEN 'Pago'
            WHEN o."DocStatus" = 'O'                        THEN 'Nao pago'
            ELSE 'Indefinido'
        END
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
        CASE WHEN i."CANCELED" = 'Y' THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN i."CANCELED"  = 'Y' THEN 'Cancelado'
            WHEN i."DocStatus" = 'C' THEN 'Fechado'
            WHEN i."DocStatus" = 'O' THEN 'Aberto'
            ELSE 'Indefinido'
        END
    FROM VW_OP_CONTRATO_VF_BASE c
    INNER JOIN OINV i  ON i."U_venda_futura" = c."ChaveOperacao"
    INNER JOIN INV1 l1 ON l1."DocEntry" = i."DocEntry"
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
        CASE WHEN r."CANCELED" = 'Y' THEN 'Sim' ELSE 'Nao' END,
        CASE
            WHEN r."CANCELED"  = 'Y' THEN 'Cancelado'
            WHEN r."DocStatus" = 'C' THEN 'Fechado'
            WHEN r."DocStatus" = 'O' THEN 'Aberto'
            ELSE 'Indefinido'
        END
    FROM VW_OP_CONTRATO_VF_BASE c
    INNER JOIN ORIN r ON r."U_venda_futura" = c."ChaveOperacao"
                     AND IFNULL(r."SeqCode", 0) <> 1
);
