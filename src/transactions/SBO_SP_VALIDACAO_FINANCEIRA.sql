CREATE OR REPLACE PROCEDURE SBO_SP_VALIDACAO_FINANCEIRA

(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),				-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255),
	INOUT error int,
	INOUT error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN

DECLARE qtdPixPendente int;
DECLARE pixDocNum int;
DECLARE pixSaldo decimal(19,6);

IF :object_type IN ('17') AND :transaction_type IN ('A','U') THEN

--    IF EXISTS (
--        SELECT
--            1
--        FROM
--            ORDR
--        WHERE
--             ORDR."BPLId" IN (2,4,11,17, 18)
--            AND ORDR."DocEntry" = :list_of_cols_val_tab_del
--            AND EXISTS (
--                SELECT
--                    1
--                FROM
--                    CLIENTEINADIMPLENTES CI
--                WHERE
--                    CI."CardCode" = ORDR."CardCode"
--            )
--    ) THEN
--
--        error := 7;
--        error_message := 'Não é permitido realizar venda para cliente com titulo vencido';
--
--    END IF;
 	IF EXISTS (
        SELECT
            1
        FROM
            ORDR
        WHERE
            ORDR."DocEntry" = :list_of_cols_val_tab_del
            AND EXISTS (
                SELECT
                    1
                FROM
                    CLIENTEINADIMPLENTES CI
                WHERE
                    CI."CardCode" = ORDR."CardCode"
            )
            AND fnValidaOtpBypass('INADIMPLENCIA', ORDR."U_otp_liberacao") = 0
    ) THEN

        error := 17;
        error_message := 'Não é permitido realizar venda para cliente com titulo vencido';

    END IF;

END IF;

-- Nota fiscal de saida de pedido com PIX pago: obriga apropriar o adiantamento ---------------
-- O PIX gerado pelo pedido (sap-service, PixController.gerarChavePixByValor) vira um
-- adiantamento ODPI com U_TX_DocTypeRef = 17 e U_TX_DocEntryRef = DocEntry do pedido.
-- Se esse adiantamento esta pago (DocStatus 'C'), sem devolucao e com saldo, a nota que vem
-- do pedido (direto ou pela entrega) tem que abater em INV9 o saldo inteiro dele.
-- Saldo = DocTotal do adiantamento - DrawnSum das outras notas nao canceladas, mesma conta do
-- sap-service (DownPayment.adiantamentoDisponivel / adiantamento-apropriado.sql).
-- Devolucao = ORIN nao cancelada com base no adiantamento (devolucao-adiantamento.sql).
IF :object_type = '13' AND :transaction_type = 'A' THEN

    pedidosDaNota =
        SELECT L."BaseEntry" AS "Pedido"
        FROM INV1 L
        INNER JOIN OINV NF ON NF."DocEntry" = L."DocEntry"
        WHERE L."DocEntry" = :list_of_cols_val_tab_del
            AND NF."CANCELED" = 'N'
            AND L."BaseType" = 17
        UNION
        SELECT E."BaseEntry" AS "Pedido"
        FROM INV1 L
        INNER JOIN OINV NF ON NF."DocEntry" = L."DocEntry"
        INNER JOIN DLN1 E ON E."DocEntry" = L."BaseEntry" AND E."LineNum" = L."BaseLine"
        WHERE L."DocEntry" = :list_of_cols_val_tab_del
            AND NF."CANCELED" = 'N'
            AND L."BaseType" = 15
            AND E."BaseType" = 17;

    pixPendente =
        SELECT
            A."DocNum",
            A."Saldo"
        FROM (
            SELECT
                DPI."DocNum",
                DPI."DocTotal" - COALESCE((
                    SELECT SUM(AP."DrawnSum")
                    FROM INV9 AP
                    INNER JOIN OINV OUTRA ON OUTRA."DocEntry" = AP."DocEntry"
                    WHERE AP."BaseAbs" = DPI."DocEntry"
                        AND OUTRA."CANCELED" = 'N'
                        AND OUTRA."DocEntry" <> :list_of_cols_val_tab_del
                ), 0) AS "Saldo",
                COALESCE((
                    SELECT SUM(AP."DrawnSum")
                    FROM INV9 AP
                    WHERE AP."BaseAbs" = DPI."DocEntry"
                        AND AP."DocEntry" = :list_of_cols_val_tab_del
                ), 0) AS "NestaNota"
            FROM ODPI DPI
            INNER JOIN :pedidosDaNota P
                ON DPI."U_TX_DocEntryRef" = P."Pedido"
            WHERE DPI."U_TX_DocTypeRef" = 17
                AND DPI."CANCELED" = 'N'
                AND DPI."DocStatus" = 'C'
                AND NOT EXISTS (
                    SELECT 1
                    FROM RIN1 DV
                    INNER JOIN ORIN DEV ON DEV."DocEntry" = DV."DocEntry"
                    WHERE DV."BaseType" = 203
                        AND DV."BaseEntry" = DPI."DocEntry"
                        AND DEV."CANCELED" = 'N'
                )
        ) A
        WHERE A."Saldo" > 0.01
            AND ABS(A."Saldo" - A."NestaNota") > 0.01;

    SELECT COUNT(1) INTO qtdPixPendente FROM :pixPendente;

    IF :qtdPixPendente > 0 THEN

        SELECT TOP 1 "DocNum", "Saldo"
        INTO pixDocNum, pixSaldo
        FROM :pixPendente
        ORDER BY "DocNum";

        error := 7;
        error_message :=
            'Pedido com PIX pago: a nota tem que usar o adiantamento ' || TO_NVARCHAR(:pixDocNum) ||
            ' no valor total do saldo (R$ ' || REPLACE(TO_NVARCHAR(CAST(ROUND(:pixSaldo, 2) AS DECIMAL(19,2))), '.', ',') || ').';

    END IF;

END IF;

END;
