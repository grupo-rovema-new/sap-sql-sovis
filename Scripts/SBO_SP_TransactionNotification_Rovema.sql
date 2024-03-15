ALTER PROCEDURE SBO_SP_TransactionNotification_Rovema
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
-- Return values
erroAdiantamento int;
begin

erroAdiantamento := 0;

/*
			                 _______   ______   _   _    _____     /\/|     ____                                                                         
				     /\     |__   __| |  ____| | \ | |  / ____|   |/\/     / __ \                                                                        
				    /  \       | |    | |__    |  \| | | |         / \    | |  | |                                                                       
				   / /\ \      | |    |  __|   | . ` | | |        / _ \   | |  | |                                                                       
				  / ____ \     | |    | |____  | |\  | | |____   / ___ \  | |__| |                                                                       
				 /_/    \_\    |_|    |______| |_| \_|  \_____| /_/   \_\  \____/                                                                        
     /\                            (_)    )_)                | |                                                                         
    /  \     _ __    __ _   _   _   _  __   __   ___       __| |   ___     _   _   ___    ___                                            
   / /\ \   | '__|  / _` | | | | | | | \ \ / /  / _ \     / _` |  / _ \   | | | | / __|  / _ \                                           
  / ____ \  | |    | (_| | | |_| | | |  \ V /  | (_) |   | (_| | |  __/   | |_| | \__ \ | (_) |                                          
 /_/    \_\ |_|     \__, |  \__,_| |_|   \_/    \___/     \__,_|  \___|    \__,_| |___/  \___/                                           
                       | |                                                                                                               
                       |_|               _                         _             _____     ____   __      __  ______   __  __            
                      | |               (_)                       | |           |  __ \   / __ \  \ \    / / |  ____| |  \/  |     /\    
   ___  __  __   ___  | |  _   _   ___   _  __   __   ___       __| |   __ _    | |__) | | |  | |  \ \  / /  | |__    | \  / |    /  \   
  / _ \ \ \/ /  / __| | | | | | | / __| | | \ \ / /  / _ \     / _` |  / _` |   |  _  /  | |  | |   \ \/ /   |  __|   | |\/| |   / /\ \  
 |  __/  >  <  | (__  | | | |_| | \__ \ | |  \ V /  | (_) |   | (_| | | (_| |   | | \ \  | |__| |    \  /    | |____  | |  | |  / ____ \ 
  \___| /_/\_\  \___| |_|  \__,_| |___/ |_|   \_/    \___/     \__,_|  \__,_|   |_|  \_\  \____/      \/     |______| |_|  |_| /_/    \_\
  _   _    /\/|             __  __               _   _    __   _                                                                         
 | \ | |  |/\/             |  \/  |             | | (_)  / _| (_)                                                                        
 |  \| |   __ _    ___     | \  / |   ___     __| |  _  | |_   _    ___    __ _   _ __                                                   
 | . ` |  / _` |  / _ \    | |\/| |  / _ \   / _` | | | |  _| | |  / __|  / _` | | '__|                                                  
 | |\  | | (_| | | (_) |   | |  | | | (_) | | (_| | | | | |   | | | (__  | (_| | | |                                                     
 |_| \_|  \__,_|  \___/    |_|  |_|  \___/   \__,_| |_| |_|   |_|  \___|  \__,_| |_|                                                     
                                                                                        
 
 * Use 
 *
 **/

---- Nota Fiscal de Saida -- Andrew Ramires May 06/03/2023
IF :object_type = '13' and (:transaction_type = 'A'or :transaction_type = 'U') then 
	SELECT
		count (1) into error
	FROM
		OINV
		LEFT JOIN OCRD on(OINV."CardCode" = OCRD."CardCode")
	WHERE 
		OCRD."U_fazer_fluxo_prazo" = '1'
		AND OINV."GroupNum" <> -1
		AND OINV."DocEntry" = :list_of_cols_val_tab_del;
			
	IF(:error > 0) THEN        
			error := 666;
         	error_message := 'Não é permitido realizar venda a prazo para cliente que não passou pelo fluxo de validação de prazo';  
	End if;

end if;

-----------------	Adiantamento fornecedor - Andrew Ramires May 06/03/2023 --------------------------------

if  :object_type = '204' and (:transaction_type = 'A'or :transaction_type = 'U') then
	Select
		count(1) into erroAdiantamento
	FROM ODPO
	WHERE
		"U_TX_DocEntryRef" in((SELECT "U_TX_DocEntryRef" FROM ODPO where "DocEntry" = :list_of_cols_val_tab_del))
		AND "CardCode" in((SELECT "CardCode" FROM ODPO where "DocEntry" = :list_of_cols_val_tab_del))
		AND NOT "DocEntry" = :list_of_cols_val_tab_del;
	IF (:erroAdiantamento > 0) THEN       
		error := '1';
    	error_message := 'Documento de adiantamento já existe';  
	END if;
END if;


-----------------	Adiantamento de cliente - Andrew Ramires May 06/03/2023 --------------------------------

if  :object_type = '203' and (:transaction_type = 'A'or :transaction_type = 'U') then
	Select
		count(1) into erroAdiantamento
	FROM ODPI
	WHERE
		"U_TX_DocEntryRef" in((SELECT "U_TX_DocEntryRef" FROM ODPI where "DocEntry" = :list_of_cols_val_tab_del))
		AND "CardCode" = (SELECT "CardCode" FROM ODPI where "DocEntry" = :list_of_cols_val_tab_del)
		AND NOT "DocEntry" = :list_of_cols_val_tab_del;
	IF (:erroAdiantamento > 0) THEN       
		error := '1';
    	error_message := 'Documento de adiantamento já existe';  
	END if;
END if;
--------------------------------------------------------------------------------------------------------------------------------


---- Nota Fiscal de Saida -- Andrew Ramires May 06/03/2023
IF :object_type = '13' and (:transaction_type = 'A'or :transaction_type = 'U') then 
	SELECT
		count (1) into error
	FROM
		OINV
		LEFT JOIN OCRD on(OINV."CardCode" = OCRD."CardCode")
	WHERE 
		OCRD."U_fazer_fluxo_prazo" = '1'
		AND OINV."GroupNum" <> -1
		AND OINV."DocEntry" = :list_of_cols_val_tab_del;
			
	IF(:error > 0) THEN        
			error := 666;
         	error_message := 'Não é permitido realizar venda a prazo para cliente que não passou pelo fluxo de validação de prazo';  
	End if;

end if;

if  :object_type = '14' and (:transaction_type = 'A'or :transaction_type = 'U') THEN
	IF EXISTS (
	Select
		1
	from ORIN T0
	INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry" 
	WHERE (T1."WhsCode" <> '500.05') AND 
	T0."BPLId" IN(2,4,11)	 AND 
	T0."Model" = 39 AND
	T0."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
	      
		error := 7;
    	error_message := 'Trocar para o depósito para o 500.05';  
	END if;

	IF NOT EXISTS (
	SELECT 1 FROM orin 
     INNER JOIN RIN21 ON orin."DocEntry" = RIN21."DocEntry"
     WHERE 
     RIN21."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
		error := 7;
    	error_message := 'Colocar referencia da nota';  
	END if;
END if;


IF :object_type = '18' and (:transaction_type = 'A' or :transaction_type = 'U') THEN
IF EXISTS(
SELECT
		1
		From "OPCH" T0						
		Where 
			T0."Model" = 0
			and 
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Informe o modelo.';  
	End If;
End If;

IF :object_type = '20' and (:transaction_type = 'A' or :transaction_type = 'U') THEN
IF EXISTS(
SELECT
		1
		From "OPDN" T0						
		Where 
			T0."Model" = 0
			and 
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Informe o modelo.';  
	End If;
End If;
end;



