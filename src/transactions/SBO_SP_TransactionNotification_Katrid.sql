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
    IF (EXISTS(SELECT * FROM "@AGROMOBI_OBJ" WHERE "U_object_type" = object_type)) THEN
        INSERT INTO "@KATRID_INTE" (
            "U_Object_Name",
            "DocEntry",
            "Object",
            "RequestStatus",
            "DocNum"
        ) VALUES (
        		 object_type,
                 COALESCE((SELECT MAX("DocEntry") + 1 FROM "@KATRID_INTE"), 1),
                 list_of_cols_val_tab_del,
                 transaction_type,
                 object_type
             );
    END IF;
END;