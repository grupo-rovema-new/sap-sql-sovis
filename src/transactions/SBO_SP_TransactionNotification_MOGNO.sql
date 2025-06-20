CREATE OR REPLACE PROCEDURE SBO_SP_TransactionNotification_MOGNO
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
error  int; -- Result (0 for no error)
error1 int;
error2 int;
error3 int;
error4 int;
erroAdiantamento int;
XITEM nvarchar (255);
XCOUNT int; -- Error string to be displayed
error_message nvarchar (255); -- Error string to be displayed
currDbNameForTaxOne nvarchar(128);
companyDbIntBank nvarchar(128);

begin

-- SAIDA DE MERCADORIA
IF :object_type = '60' and (:transaction_type = 'A') then 

    --TRAVA PARA NÃO PERMITIR SAÍDA DE MERCADORIA QUE DEIXE O ITEM COM ESTOQUE NEGATIVO COM DATA RETROATIVA.
    --PAULO 15/06/2025 
	SELECT 
     	Count(T0."ItemCode")
     	INTO
     	error1
     FROM 
     	IGE1 T0 
     	JOIN OINM T1 ON T1."ItemCode" = T0."ItemCode" AND T1."Warehouse" = T0."WhsCode" 
    WHERE
    	T0."DocEntry"  = :list_of_cols_val_tab_del
	GROUP BY
		T0."ItemCode",
		T0."Quantity"
     HAVING 
     	SUM(T1."InQty" - T1."OutQty") - T0."Quantity" < 0;

	  IF(:error1 > 0) THEN        

		SELECT 
			(T0."ItemCode") 
			INTO XITEM
		FROM 
			IGE1 T0 
     		JOIN OINM T1 ON T1."ItemCode" = T0."ItemCode" AND T1."Warehouse" = T0."WhsCode" 
    	WHERE
    		T0."DocEntry"  = :list_of_cols_val_tab_del
		GROUP BY
			T0."ItemCode",
			T0."Quantity"
	     HAVING 
    	 	SUM(T1."InQty" - T1."OutQty") - T0."Quantity" < 0
         LIMIT 1;
         
			error := 1;
			
         	error_message := CONCAT('O Item ficará com estoque negativo: ', XITEM) ;  

	  END IF;
END IF;


end;