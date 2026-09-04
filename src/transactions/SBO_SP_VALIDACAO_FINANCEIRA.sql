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

IF :object_type IN ('17') AND :transaction_type IN ('A','U') THEN

    IF EXISTS (
        SELECT
            1
        FROM
            ORDR
        WHERE
             ORDR."BPLId" IN (2,4,11,17, 18)
            AND ORDR."DocEntry" = :list_of_cols_val_tab_del
            AND EXISTS (
                SELECT
                    1
                FROM
                    CLIENTEINADIMPLENTES CI
                WHERE
                    CI."CardCode" = ORDR."CardCode"
            )
    ) THEN

        error := 7;
        error_message := 'Não é permitido realizar venda para cliente com titulo vencido';

    END IF;

END IF;

END;
