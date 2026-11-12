-- Titulos de cartao de credito e cheque recebidos de clientes
--
-- Objetivo: base unica para o relatorio gerencial de conferencia da carteira de
-- cheques e cartoes. Cada linha e um titulo:
--   Cheque  -> um cheque recebido (RCT1), com os dados bancarios da folha.
--   Cartao  -> uma parcela do voucher de cartao (RCT3), explodida por NumOfPmnts.
--
-- Status (coluna "StatusCod" / "Status"):
--   'A' Em aberto  -> ainda nao depositado / nao creditado pela administradora
--   'L' Liquidado  -> ja depositado (Banco > Depositos)
--   'C' Cancelado  -> recebimento ou cheque cancelado
--
-- Como o SAP marca a liquidacao de cada meio:
--   Cheque: OCHH."Deposited" = 'N' (em aberto), 'C' (depositado como caixa, ODPS)
--           ou 'S' (depositado pre-datado, ODPT). O vinculo RCT1 -> OCHH e por
--           RCT1."CheckAbs" = OCHH."CheckKey".
--   Cartao: o SAP NAO guarda uma linha de deposito por voucher (DPS1 so tem
--           cheques). O que ele faz e conciliar internamente o lancamento do
--           voucher na conta transitoria de cartoes. Entao aqui o titulo e
--           considerado liquidado quando o saldo em aberto (JDT1."BalDueDeb" -
--           "BalDueCred") daquela conta, no lancamento contabil do recebimento,
--           chega a zero. O numero/data do deposito vem pela conciliacao (ITR1)
--           casada com o lancamento de um deposito de vouchers (ODPS."DeposType" = 'V').
--
-- Observacoes de leitura (importantes para a conferencia):
--   1. Parcelas de cartao: se o voucher ja foi dividido pelo SAP
--      (RCT3."SpiltCred" = 'Y') cada linha do RCT3 ja e uma parcela e nao e
--      reexplodida. Caso contrario a parcela 1 vale "FirstSum" e as demais
--      "AddPmntSum"; se ambos vierem zerados o valor e rateado igualmente.
--   2. Status de cartao e por voucher, nao por parcela - o SAP concilia o
--      lancamento inteiro. Todas as parcelas do mesmo voucher herdam o status.
--   3. "Valor" esta na moeda do titulo ("Moeda"), nao convertido.
--   4. Cheque endossado a terceiro (OCHH."Converted" = 'Y') continua aparecendo
--      como em aberto, porque nao houve deposito. Se precisar separar, use a
--      coluna e crie um quarto status.
--   5. A explosao de parcelas usa SERIES_GENERATE_INTEGER (limite de 120
--      parcelas). Se a versao do HANA nao tiver a funcao, troque o CTE
--      "parcelas" por um SELECT com UNION ALL de 1 ate o maximo necessario.
--   6. Titulo cancelado sai sempre com "SaldoEmAberto" = 0. Sem isso o cartao
--      cancelado caia no ELSE e levava o valor cheio do voucher para o saldo,
--      inflando o total de "em aberto" do relatorio.
--
-- Usada pela consulta do Query Manager em doc/.

CREATE OR REPLACE VIEW CR_TITULOS_CARTAO_CHEQUE AS

WITH bancos AS (
    -- ODSC pode repetir o mesmo BankCode por pais; deduplica para nao multiplicar linha
    SELECT
        "BankCode",
        MIN("BankName") AS "BankName"
    FROM ODSC
    GROUP BY "BankCode"
),

notas AS (
    -- notas fiscais quitadas por cada recebimento (RCT2."DocNum" = ORCT."DocEntry")
    SELECT
        r."RecebimentoEntry",
        STRING_AGG(TO_NVARCHAR(r."DocNum"), ', ') AS "NotasFiscais",
        STRING_AGG(r."Serial", ', ')              AS "NFe"
    FROM (
        SELECT DISTINCT
            p."DocNum" AS "RecebimentoEntry",
            nf."DocNum",
            nf."Serial"
        FROM RCT2 p
        INNER JOIN OINV nf
            ON nf."DocEntry" = p."DocEntry"
        WHERE p."InvType" = 13
    ) r
    GROUP BY r."RecebimentoEntry"
),

razao AS (
    -- saldo em aberto do lancamento contabil do recebimento, por conta
    SELECT
        j."TransId",
        j."Account",
        SUM(j."Debit" - j."Credit")                   AS "ValorLancado",
        SUM(j."BalDueDeb") - SUM(j."BalDueCred")      AS "SaldoEmAberto"
    FROM JDT1 j
    WHERE j."Account" IN (
        -- so as contas transitorias de cartao, senao varre o razao inteiro
        SELECT DISTINCT c."CreditAcct"
        FROM RCT3 c
        WHERE c."CreditAcct" IS NOT NULL
    )
    GROUP BY j."TransId", j."Account"
),

deposito_cartao AS (
    -- deposito de vouchers alcancado pela conciliacao interna do lancamento
    SELECT
        origem."TransId"                    AS "TransIdRecebimento",
        origem."Account",
        MIN(dep."DeposNum")                 AS "DepositoNum",
        MIN(dep."DeposDate")                AS "DataDeposito",
        COUNT(DISTINCT dep."DeposId")       AS "QtdDepositos"
    FROM ITR1 origem
    INNER JOIN ITR1 contrapartida
        ON  contrapartida."ReconNum" = origem."ReconNum"
        AND contrapartida."TransId" <> origem."TransId"
    INNER JOIN ODPS dep
        ON  dep."TransAbs"  = contrapartida."TransId"
        AND dep."DeposType" = 'V'
        AND dep."Canceled"  = 'N'
    GROUP BY origem."TransId", origem."Account"
),

parcelas AS (
    SELECT GENERATED_PERIOD_START AS "Parcela"
    FROM SERIES_GENERATE_INTEGER(1, 1, 121)
),

cartao_base AS (
    SELECT
        rct."DocEntry",
        rct."DocNum",
        rct."DocDate",
        rct."TransId",
        rct."BPLId",
        rct."CardCode",
        rct."CardName",
        rct."Canceled",
        cc."LineID",
        cc."CreditCard",
        cc."VoucherNum",
        cc."ConfNum",
        cc."CreditSum",
        cc."CreditCur",
        cc."CreditAcct",
        cc."FirstDue",
        cc."FirstSum",
        cc."AddPmntSum",
        cc."SpiltCred",
        CASE
            WHEN COALESCE(cc."SpiltCred", 'N') = 'Y' THEN 1
            ELSE GREATEST(COALESCE(cc."NumOfPmnts", 1), 1)
        END AS "TotalParcelas"
    FROM ORCT rct
    INNER JOIN RCT3 cc
        ON cc."DocNum" = rct."DocEntry"
)

-- ---------------------------------------------------------------- CHEQUES
SELECT
    'Cheque'                                        AS "Tipo",
    CASE
        WHEN rct."Canceled" = 'Y'
          OR COALESCE(ch."Canceled", 'N') = 'Y'          THEN 'C'
        WHEN COALESCE(ch."Deposited", 'N') = 'N'         THEN 'A'
        ELSE 'L'
    END                                             AS "StatusCod",
    CASE
        WHEN rct."Canceled" = 'Y'
          OR COALESCE(ch."Canceled", 'N') = 'Y'          THEN 'Cancelado'
        WHEN COALESCE(ch."Deposited", 'N') = 'N'         THEN 'Em aberto'
        ELSE 'Liquidado'
    END                                             AS "Status",
    rct."BPLId"                                     AS "Filial",
    fil."BPLName"                                   AS "NomeFilial",
    rct."CardCode",
    COALESCE(pn."CardName", rct."CardName")         AS "Cliente",
    rct."DocNum"                                    AS "RecebimentoNum",
    rct."DocEntry"                                  AS "RecebimentoEntry",
    rct."DocDate"                                   AS "DataRecebimento",
    COALESCE(chq."DueDate", rct."DocDate")          AS "Vencimento",
    1                                               AS "Parcela",
    1                                               AS "TotalParcelas",
    chq."CheckSum"                                  AS "Valor",
    chq."CheckSum"                                  AS "ValorDocumento",
    COALESCE(chq."Currency", rct."DocCurr")         AS "Moeda",
    COALESCE(bco."BankName", chq."BankCode")        AS "Instituicao",
    TO_NVARCHAR(chq."CheckNum")                     AS "Documento",
    chq."Branch"                                    AS "Agencia",
    chq."AcctNum"                                   AS "ContaCorrente",
    CAST(NULL AS NVARCHAR(100))                     AS "Autorizacao",
    chq."CheckAct"                                  AS "ContaTransitoria",
    COALESCE(TO_NVARCHAR(dps."DeposNum"),
             TO_NVARCHAR(dpt."DeposId"))            AS "DepositoNum",
    COALESCE(dps."DeposDate", dpt."DeposDate")      AS "DataDeposito",
    CASE
        WHEN rct."Canceled" = 'Y'
          OR COALESCE(ch."Canceled", 'N') = 'Y'      THEN 0
        WHEN COALESCE(ch."Deposited", 'N') = 'N'     THEN chq."CheckSum"
        ELSE 0
    END                                             AS "SaldoEmAberto",
    nf."NotasFiscais",
    nf."NFe"
FROM ORCT rct
INNER JOIN RCT1 chq
    ON chq."DocNum" = rct."DocEntry"
LEFT JOIN OCHH ch
    ON ch."CheckKey" = chq."CheckAbs"
LEFT JOIN ODPS dps
    ON dps."DeposId" = ch."DpstAbs"
LEFT JOIN ODPT dpt
    ON dpt."DeposId" = ch."DepNum2"
LEFT JOIN bancos bco
    ON bco."BankCode" = chq."BankCode"
LEFT JOIN OBPL fil
    ON fil."BPLId" = rct."BPLId"
LEFT JOIN OCRD pn
    ON pn."CardCode" = rct."CardCode"
LEFT JOIN notas nf
    ON nf."RecebimentoEntry" = rct."DocEntry"

UNION ALL

-- ---------------------------------------------------------------- CARTOES
SELECT
    'Cartao'                                        AS "Tipo",
    CASE
        WHEN cb."Canceled" = 'Y'                         THEN 'C'
        WHEN dep."DepositoNum" IS NOT NULL               THEN 'L'
        WHEN rz."SaldoEmAberto" IS NOT NULL
         AND ABS(rz."SaldoEmAberto") < 0.005             THEN 'L'
        ELSE 'A'
    END                                             AS "StatusCod",
    CASE
        WHEN cb."Canceled" = 'Y'                         THEN 'Cancelado'
        WHEN dep."DepositoNum" IS NOT NULL               THEN 'Liquidado'
        WHEN rz."SaldoEmAberto" IS NOT NULL
         AND ABS(rz."SaldoEmAberto") < 0.005             THEN 'Liquidado'
        ELSE 'Em aberto'
    END                                             AS "Status",
    cb."BPLId"                                      AS "Filial",
    fil."BPLName"                                   AS "NomeFilial",
    cb."CardCode",
    COALESCE(pn."CardName", cb."CardName")          AS "Cliente",
    cb."DocNum"                                     AS "RecebimentoNum",
    cb."DocEntry"                                   AS "RecebimentoEntry",
    cb."DocDate"                                    AS "DataRecebimento",
    ADD_MONTHS(COALESCE(cb."FirstDue", cb."DocDate"),
               pc."Parcela" - 1)                    AS "Vencimento",
    pc."Parcela",
    cb."TotalParcelas",
    CASE
        WHEN cb."TotalParcelas" <= 1 THEN cb."CreditSum"
        WHEN COALESCE(cb."FirstSum", 0) = 0
         AND COALESCE(cb."AddPmntSum", 0) = 0
            THEN cb."CreditSum" / cb."TotalParcelas"
        WHEN pc."Parcela" = 1 THEN cb."FirstSum"
        ELSE cb."AddPmntSum"
    END                                             AS "Valor",
    cb."CreditSum"                                  AS "ValorDocumento",
    cb."CreditCur"                                  AS "Moeda",
    adm."CardName"                                  AS "Instituicao",
    cb."VoucherNum"                                 AS "Documento",
    CAST(NULL AS NVARCHAR(50))                      AS "Agencia",
    CAST(NULL AS NVARCHAR(50))                      AS "ContaCorrente",
    cb."ConfNum"                                    AS "Autorizacao",
    cb."CreditAcct"                                 AS "ContaTransitoria",
    TO_NVARCHAR(dep."DepositoNum")                  AS "DepositoNum",
    dep."DataDeposito",
    CASE
        WHEN cb."Canceled" = 'Y'                     THEN 0
        WHEN rz."SaldoEmAberto" IS NOT NULL          THEN rz."SaldoEmAberto"
        WHEN dep."DepositoNum" IS NOT NULL           THEN 0
        ELSE cb."CreditSum"
    END                                             AS "SaldoEmAberto",
    nf."NotasFiscais",
    nf."NFe"
FROM cartao_base cb
INNER JOIN parcelas pc
    ON pc."Parcela" <= cb."TotalParcelas"
LEFT JOIN OCRC adm
    ON adm."CreditCard" = cb."CreditCard"
LEFT JOIN razao rz
    ON  rz."TransId" = cb."TransId"
    AND rz."Account" = cb."CreditAcct"
LEFT JOIN deposito_cartao dep
    ON  dep."TransIdRecebimento" = cb."TransId"
    AND dep."Account"            = cb."CreditAcct"
LEFT JOIN OBPL fil
    ON fil."BPLId" = cb."BPLId"
LEFT JOIN OCRD pn
    ON pn."CardCode" = cb."CardCode"
LEFT JOIN notas nf
    ON nf."RecebimentoEntry" = cb."DocEntry";
