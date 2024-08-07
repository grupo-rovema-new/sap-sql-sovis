CREATE OR REPLACE PROCEDURE SBO_SP_TransactionNotification_Katrid
(
	in object_type nvarchar(30),
	in transaction_type nchar(1),
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
	-- PARCEIRO DE NEGOCIO
	IF ((:object_type = '2') and (:transaction_type = 'A' or :transaction_type = 'U')) THEN
		INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'BusinessPartners',
				coalesce(
					(
						select
							max("DocEntry") + 1
						from
							"@KATRID_INTE"
					),
					1
				),
				list_of_cols_val_tab_del,
				transaction_type
			);

	-- ITEM
	ELSEIF ((:object_type='4') AND (:transaction_type = 'A' or :transaction_type = 'U')) THEN
	INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'Items',
				coalesce(
					(
						select
							max("DocEntry") + 1
						from
							"@KATRID_INTE"
					),
					1
				),
				list_of_cols_val_tab_del,
				transaction_type
			);

	-- UTILIZAÇÕES
	ELSEIF ((:object_type='260') AND (:transaction_type = 'A' or :transaction_type = 'U')) THEN
	INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'NotaFiscalUsage',
				coalesce(
					(
						select
							max("DocEntry") + 1
						from
							"@KATRID_INTE"
					),
					1
				),
				list_of_cols_val_tab_del,
				transaction_type
			);
	END IF;
end;