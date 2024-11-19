CREATE OR REPLACE PROCEDURE SBO_SP_TransactionNotification_Katrid (
    IN object_type NVARCHAR(30),
    IN transaction_type NCHAR(1),
    IN num_of_cols_in_key INT,
    IN list_of_key_cols_tab_del NVARCHAR(255),
    IN list_of_cols_val_tab_del NVARCHAR(255),
    INOUT error INT,
    INOUT error_message NVARCHAR(200)
) LANGUAGE SQLSCRIPT SQL SECURITY INVOKER AS
BEGIN
    IF (transaction_type = 'A' OR transaction_type = 'U') THEN
        -- PARCEIRO DE NEGOCIO
        IF (object_type = '2') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'BusinessPartners',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '2'
            );

        -- ITEM
        ELSEIF (object_type = '4') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "Remark",
                "DocNum"
            ) VALUES (
                'SQLQueries(''Sql_Items'')/List',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                '''' || TO_VARCHAR(list_of_cols_val_tab_del) || '''',
                transaction_type,
                'item',
                '4'
            );

 /*       -- DEP ITEM
        ELSEIF (object_type = '31') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "Remark",
                "DocNum"
            ) VALUES (
                'SQLQueries(''Sql_Items'')/List',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                '''' || SUBSTRING(TO_VARCHAR(list_of_cols_val_tab_del), 1, 11) || '''',
                transaction_type,
                'item',
                '31'
            );*/

        -- UTILIZAÇÕES
        ELSEIF (object_type = '260') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'NotaFiscalUsage',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '260'
            );

        -- NF DE SAIDA
        ELSEIF (object_type = '13') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'Invoices',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '13'
            );

        -- NF DE ENTRADA
        ELSEIF (object_type = '18') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'PurchaseInvoices',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '18'
            );

        -- DEV DE SAIDA
        ELSEIF (object_type = '14') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'CreditNotes',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '14'
            );

        -- DEV DE ENTRADA
        ELSEIF (object_type = '19') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'PurchaseCreditNotes',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '19'
            );

        -- ENTREGA
        ELSEIF (object_type = '15') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'DeliveryNotes',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '15'
            );
           
           -- RECEBIMENTO
        ELSEIF (object_type = '20') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "DocNum"
            ) VALUES (
                'PurchaseDeliveryNotes',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                list_of_cols_val_tab_del,
                transaction_type,
                '20'
            );

        -- LOTES
        ELSEIF (object_type = '106') THEN -- Corrigido para um tipo diferente
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "Remark",
                "DocNum"
            ) VALUES (
                'SQLQueries(''Sql_Lotes'')/List',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                '''' || TO_VARCHAR(list_of_cols_val_tab_del) || '''',
                transaction_type,
                'batchnum',
                '106'
            );

        -- ALTERAÇÃO DE CUSTO
        ELSEIF (object_type = '58') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "Remark",
                "DocNum"
            ) VALUES (
                'SQLQueries(''Sql_Items_Custo'')/List',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                '''' || TO_VARCHAR(list_of_cols_val_tab_del) || '''',
                transaction_type,
                'transnum',
                '58'
            );

        -- TRANSFERENCIA DE DEPOSITO
        ELSEIF (object_type = '67') THEN
            INSERT INTO "@KATRID_INTE" (
                "U_Object_Name",
                "DocEntry",
                "Object",
                "RequestStatus",
                "Remark",
                "DocNum"
            )
            SELECT 
                'SQLQueries(''Sql_Items'')/List',
                COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                '''' || TO_VARCHAR("ItemCode") || '''',
                transaction_type,
                'item',
                '67'
            FROM WTR1
            WHERE "DocEntry" = list_of_cols_val_tab_del;

        END IF; 
    END IF;
END;
