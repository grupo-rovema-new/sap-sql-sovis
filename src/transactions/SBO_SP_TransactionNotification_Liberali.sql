CREATE OR REPLACE PROCEDURE SBO_SP_TransactionNotification_Liberali
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255),
	INOUT error int,
	INOUT error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS


begin

-------------------TRAVA ROMANEIO DE PESAGEM - B1ACM -----------------------------------
IF	:object_type = 'AMFS_UDO_RETR'	AND (:transaction_type = 'U' OR :transaction_type = 'A') THEN
IF	EXISTS (
		SELECT
			1
		FROM
			"@AMFS_RETR" T0
		WHERE
			T0."U_PesoBruto" = 0
			AND T0."U_PesoTara" = 0
			AND T0."DocEntry" = :list_of_cols_val_tab_del
) THEN 
	error := 3;
	error_message := 'Não é permitido adicionar o romaneio sem pesagem"';
END IF;
END IF;
---------------TRAVA ROMANEIO x ENTREGA - CLI SOMENTE NF COM REFERENCIA ----------------
IF	:object_type = '15'	AND (:transaction_type = 'U' OR :transaction_type = 'A') THEN
IF EXISTS (
	SELECT 
		1
    FROM ODLN T0
    LEFT JOIN DLN21 T1 
        ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN "@AMFS_CNTR" T2
        ON T0."U_LbrAmfsCodContrato" = T2."Code"
    WHERE 
        T0."DocEntry" = :list_of_cols_val_tab_del
        AND T2."U_CodParceiroNegocio" LIKE 'CLI%'
        AND T0."U_LbrAmfsCodContrato" IS NOT NULL
        AND T1."DocEntry" IS NULL
) THEN 
	error := 3;
	error_message := 'Parceiros CLI não é permitido gerar a NF sem referência! ';
END IF;
END IF;

end;

