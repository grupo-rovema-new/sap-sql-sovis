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
IF (:transaction_type = 'A' or :transaction_type = 'U') THEN
	-- PARCEIRO DE NEGOCIO
	IF (:object_type = '2') THEN
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
	ELSEIF (:object_type = '4') THEN
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
	ELSEIF (:object_type = '260') THEN
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
	
	-- NF DE SAIDA
	ELSEIF((:object_type = '13') ) THEN
		INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'Invoices',
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
	
	-- NF DE ENTRADA
	ELSEIF((:object_type = '18') ) THEN
		INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'PurchaseInvoices',
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
		
	-- DEV DE SAIDA
	ELSEIF((:object_type = '14') ) THEN
		INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'CreditNotes',
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
	
	-- DEV DE ENTRADA
	ELSEIF((object_type = '19') THEN
		INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'PurchaseCreditNotes',
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
	
	-- ENTREGA
	ELSEIF(:object_type = '15') THEN
		INSERT INTO
			"@KATRID_INTE" (
				"U_Object_Name",
				"DocEntry",
				"Object",
				"RequestStatus"
			)
		values
			(
				'DeliveryNotes',
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
END IF;
end;
  