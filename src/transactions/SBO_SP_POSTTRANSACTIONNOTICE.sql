CREATE  PROCEDURE SBO_SP_PostTransactionNotice
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
-- Return values
error  int;				-- Result (0 for no error)
error_message nvarchar (200); 		-- Error string to be displayed
db_invname nvarchar(128);
begin

error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------

--	ADD	YOUR	CODE	HERE
-----------------------------------------NOTA DE ENTRADA------------------------------------------------------------------------
------CAMPOS DE USUARIOS REINF------
IF :object_type = '18' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    IF EXISTS (SELECT 1 FROM PCH1 WHERE "TaxCode" IN ('5501-002') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OPCH SET "U_TX_RF_TObr" = 0, "U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 9,"U_TX_RF_IAquis" = 0 WHERE OPCH."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
    IF EXISTS (SELECT 1 FROM PCH1 WHERE "TaxCode" IN ('5101-002', '5101-03', '5101-015', '5101-019', '5101-020') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OPCH SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 1,"U_TX_RF_IAquis" = 0 WHERE OPCH."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
       IF EXISTS (SELECT 1 FROM PCH1 WHERE "TaxCode" IN ('5101-011', '5101-012', '5101-016', '5101-017', '6101-008', '6108-005') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OPCH SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 7,"U_TX_RF_IAquis" = 0 WHERE OPCH."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
       IF EXISTS (SELECT 1 FROM PCH1 WHERE "TaxCode" IN ('1102-09', '1102-010', '1101-010', '1101-012') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OPCH SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 0,"U_TX_RF_IAquis" = 4 WHERE OPCH."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
        IF EXISTS (SELECT 1 FROM PCH1 WHERE "TaxCode" IN ('1102-008', '1102-012', '1102-013', '1101-011', '1101-013') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OPCH SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 0,"U_TX_RF_IAquis" = 1  WHERE OPCH."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
END IF;

IF :object_type = '13' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    IF EXISTS (SELECT 1 FROM INV1 WHERE "TaxCode" IN ('5501-002') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OINV SET "U_TX_RF_TObr" = 0, "U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 9,"U_TX_RF_IAquis" = 0 WHERE OINV."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
    IF EXISTS (SELECT 1 FROM INV1 WHERE "TaxCode" IN ('5101-002', '5101-03', '5101-015', '5101-019', '5101-020') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OINV SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 1,"U_TX_RF_IAquis" = 0 WHERE OINV."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
       IF EXISTS (SELECT 1 FROM INV1 WHERE "TaxCode" IN ('5101-011', '5101-012', '5101-016', '5101-017', '6101-008', '6108-005') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OINV SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 7,"U_TX_RF_IAquis" = 0 WHERE OINV."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
       IF EXISTS (SELECT 1 FROM INV1 WHERE "TaxCode" IN ('1102-09', '1102-010', '1101-010', '1101-012') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OINV SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 0,"U_TX_RF_IAquis" = 4 WHERE OINV."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
   
        IF EXISTS (SELECT 1 FROM INV1 WHERE "TaxCode" IN ('1102-008', '1102-012', '1102-013', '1101-011', '1101-013') AND "DocEntry" = :list_of_cols_val_tab_del) THEN
        UPDATE OINV SET "U_TX_RF_TObr" = 0,"U_TX_RF_TRep" = 0,"U_TX_RF_ICom" = 0,"U_TX_RF_IAquis" = 1  WHERE OINV."DocEntry" = :list_of_cols_val_tab_del;
    END IF;
END IF;

----------------------------CAMPOS DE USUARIOS INDICADOR DA NATUREZA DO FRETE-----------------------------------
IF :object_type = '20' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
IF EXISTS (SELECT 1 FROM PCH1 WHERE "CSTfCOFINS" = 50 AND "CSTfPIS" = 50 AND "Usage" = 24 AND "DocEntry" = :list_of_cols_val_tab_del) THEN
UPDATE OPCH SET "U_TX_IndNatFrete" = 9 WHERE OPCH."DocEntry" = :list_of_cols_val_tab_del;
END IF;
END IF;

--------------------------------------------------------------------------------------------------------------------------------


--Start InvoiceOne
/*
SELECT CURRENT_SCHEMA INTO db_invname FROM DUMMY;
Call "TransNoticeNfe" 
	(:db_invname, :object_type, :transaction_type, :num_of_cols_in_key
	,:list_of_key_cols_tab_del, :list_of_cols_val_tab_del);


Call "UpdateStatusDocReceived" 
	(:db_invname, :object_type, :transaction_type, :num_of_cols_in_key
	,:list_of_key_cols_tab_del, :list_of_cols_val_tab_del);
--End InvoiceOne--Start TaxOneInvoice

SELECT CURRENT_SCHEMA INTO db_invname FROM DUMMY;
Call "TransNoticeNfse" 
	(:db_invname, :object_type, :transaction_type, :num_of_cols_in_key
	,:list_of_key_cols_tab_del, :list_of_cols_val_tab_del);

--End TaxOneInvoice
*/
--------------
--Start TaxOneInvoice

SELECT CURRENT_SCHEMA INTO db_invname FROM DUMMY;
Call "TransNoticeNfse"
(:db_invname, :object_type, :transaction_type, :num_of_cols_in_key
,:list_of_key_cols_tab_del, :list_of_cols_val_tab_del);
--End TaxOneInvoice
--Start InvoiceOne

SELECT CURRENT_SCHEMA INTO db_invname FROM DUMMY;
Call "TransNoticeNfe"
(:db_invname, :object_type, :transaction_type, :num_of_cols_in_key
,:list_of_key_cols_tab_del, :list_of_cols_val_tab_del);

Call "UpdateStatusDocReceived"
(:db_invname, :object_type, :transaction_type, :num_of_cols_in_key
,:list_of_key_cols_tab_del, :list_of_cols_val_tab_del);
--End InvoiceOne

-- Select the return values
select :error, :error_message FROM dummy;

end;
