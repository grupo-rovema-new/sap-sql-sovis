CREATE OR REPLACE PROCEDURE SBO_SP_TransactionNotification_Rovema
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

	IF EXISTS (
	Select
		1
	from OINV T0
	INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
	
	WHERE 
	T1."Price" <= 0
	AND
	T0."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
	      
		error := 7;
    	error_message := 'Informar preço unitario'; 

end if;

 IF EXISTS (
 SELECT
		1
	FROM
		OINV
		LEFT JOIN OCRD on(OINV."CardCode" = OCRD."CardCode")
	WHERE 
		OCRD."U_fazer_fluxo_prazo" = '1'
		AND OINV."GroupNum" <> -1
		AND OINV."DocEntry" = :list_of_cols_val_tab_del
			) THEN        
			error := 666;
         	error_message := 'Não é permitido realizar venda a prazo para cliente que não passou pelo fluxo de validação de prazo';  
	End if;
IF EXISTS (
	Select
		1
	from OINV T0
	INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
	
	WHERE 
	T0."DocType" = 'S' AND 
	T1."AcctCode" = '1.9.1.001.00002' AND 
	T0."SeqCode" <> 29 AND
	T0."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
	      
		error := 7;
    	error_message := 'Favor colocar a sequencia como FIN'; 

end if;


End If;
-----------------------------------------------------------------------------------------------

--------------- NOTA DE ENTREGA ---------------------------------------------------------------
IF :object_type = '15' and (:transaction_type = 'A'or :transaction_type = 'U') then 
	IF EXISTS (
		Select
			1
		from ODLN T0
		INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		
		WHERE 
		T1."Price" <= 0
		AND
		T0."DocEntry" = :list_of_cols_val_tab_del
		)
		THEN
		      
			error := 7;
	    	error_message := 'Informar preço unitario'; 
	END IF;
END IF;

-----------------------------------------------------------------------------------------------------------

-------------------DEVOLUÇÃO DE NOTA FISCAL DE SAIDA-------------------------------------------------------
if  :object_type = '14' and (:transaction_type = 'A'or :transaction_type = 'U') THEN
	IF EXISTS (
		Select
			1
		from ORIN T0
		INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		WHERE (T1."WhsCode" <> '500.05') AND 
		T0."BPLId" = 2	 AND
		T0."Model" = 39 AND
		T1."Usage" <> 100 AND  
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

---------------------------------------------------------------------------------------

-----------------------NOTA DE ENTRADA---------------------------------------------------
IF :object_type = '18' and (:transaction_type = 'A' or :transaction_type = 'U') THEN
IF EXISTS(
SELECT
		1
		From "OPCH" T0						
		Where 
			T0."Model" = 0 and
			T0.CANCELED = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Informe o modelo.';  
	End If;
	IF EXISTS (
	Select
		1
	from OPCH T0
	INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
	
	WHERE 
	T1."Price" <= 0
	AND
	T0."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
	      
		error := 7;
    	error_message := 'Informar preço unitario';  
	END if;
IF EXISTS(
	Select 
		1
		From "OPCH" T0						
 		inner join "PCH12" on "PCH12"."DocEntry" = T0."DocEntry"
		Where 
			T0."Model" not in ('28','46','37','47')
			and
			Substring("U_ChaveAcesso",23,3) not like '%'|| T0."SeriesStr" || '%'
			and 
			 T0."CANCELED" = 'N'
			and ifnull(T0."U_ChaveAcesso",'') <> ''
			and 
			T0."DocEntry" = :list_of_cols_val_tab_del		
)
		 THEN        
			error := 7;
         	error_message := 'Informações da Série não confere com Chave de acesso.';  
	End if;	
IF EXISTS(
SELECT
		1
		From "OPCH" T0		
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 34 and
			T0."Model" NOT IN (46,19,18) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque o modelo NFS-E';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPCH" T0		
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 72 and
			T0."Model" NOT IN (46,28) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque o modelo NFS-E ou FAT';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPCH" T0		
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 24 and
			T0."Model" <> 45 and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque o Modelo57';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPCH" T0		
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 14 and
			T0."Model" NOT IN (19,18) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del 
			
) 

       	 Then       
			error := 7;
         	error_message := 'Nota de telecomunicação deve ser modelo 21 ou modelo 22';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPCH" T0		
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 34 and
			T0."Model" NOT IN (46,19,18,72) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del AND
			(T0."U_ChaveAcesso" <> '' OR T0."U_ChaveAcesso" IS NOT NULL)
			
) 

       	 Then       
			error := 7;
         	error_message := 'Nota de serviço não precisa de chave de acesso';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPCH" T0	
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
		Where 
			T0."DocType" <> 'S' AND 
			T1."Usage" NOT IN(14,34,24,33,73,74,36,13,72) AND 
			T0."Model" <> 39 AND 
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque modelo como NFE 55';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPCH" T0	
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
		Where 
			T1."Usage" NOT IN(14,34,24,33,73,74,36,13,72) AND 
			T0."Model" = 39 AND 
			T0."SeqCode" = '-2' AND
			T0."CANCELED" = 'N' AND
			(T0."U_ChaveAcesso" = '' OR T0."U_ChaveAcesso" IS NULL)  AND 
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'E necessario chave de acesso';  
	End If;
  IF EXISTS(
	SELECT 
		1
		FROM "OPCH" T0
 		WHERE 
 		T0."CardCode" <> 'FOR0000116' AND 
 		T0."DiscPrcnt" <> 0 AND 
 		T0."DocEntry" = :list_of_cols_val_tab_del
   )
   THEN 
   		error := 7;
    	error_message := 'O desconto deve ser informado na linha'; 
 END IF;
END IF;
------------------------------------------------------------------------------------------------


----------------------------------RECEBIMENTO DE MERCADORIA-------------------------------------
IF :object_type = '20' and (:transaction_type = 'A' or :transaction_type = 'U') THEN
IF EXISTS(
SELECT
		1
		From "OPDN" T0						
		Where 
			T0."Model" = 0 and 
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
) 

       	 Then       
			error := 7;
         	error_message := 'Informe o modelo.';  
	End If;
IF EXISTS (
	Select
		1
	from OPDN T0
	INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
	
	WHERE 
	T1."Price" <= 0
	AND
	T0."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
	      
		error := 7;
    	error_message := 'Informar preço unitario';  
	END if;
IF EXISTS(
	Select 
		1
		From "OPDN" T0						
 		inner join "PDN12" on "PDN12"."DocEntry" = T0."DocEntry"
		Where 
			T0."Model" not in ('28','46','37','47')
			and
			Substring("U_ChaveAcesso",23,3) not like '%'|| T0."SeriesStr" || '%'
			and 
			 T0."CANCELED" = 'N'
			and ifnull(T0."U_ChaveAcesso",'') <> ''
			and 
			T0."DocEntry" = :list_of_cols_val_tab_del		
)
		 THEN        
			error := 7;
         	error_message := 'Informações da Série não confere com Chave de acesso.';  
	End if;	
IF EXISTS(
SELECT
		1
		From "OPDN" T0		
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 34 and
			T0."Model" NOT IN (46,19,18) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque o modelo NFS-E';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPDN" T0		
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 72 and
			T0."Model" NOT IN (46,28) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque o modelo NFS-E ou FAT';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPDN" T0		
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 24 and
			T0."Model" <> 45 and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque o Modelo57';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPDN" T0		
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 34 and
		    T0."Model" NOT IN (46,19,18) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del AND
			(T0."U_ChaveAcesso" <> '' OR T0."U_ChaveAcesso" IS NOT NULL)
			
) 

       	 Then       
			error := 7;
         	error_message := 'Nota de serviço não precisa de chave de acesso';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPDN" T0	
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry"
		Where 
			T1."Usage" NOT IN(14,34,24,33,73,74,36,13,72) AND 
			T0."Model" <> 39 AND 
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Coloque modelo como NFE 55';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPDN" T0	
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry"
		Where 
			T1."Usage" NOT IN(14,34,24,33,73,74,36,72) AND 
			T0."Model" = 39 AND 
			T0."SeqCode" = '-2' AND
			T0."CANCELED" = 'N' AND
			(T0."U_ChaveAcesso" = '' OR T0."U_ChaveAcesso" IS NULL)  AND 
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'E necessario chave de acesso';  
	End If;
IF EXISTS(
SELECT
		1
		From "OPDN" T0		
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" = 14 and
			T0."Model" NOT IN (19,18) and
			T0."CANCELED" = 'N' and
			T0."DocEntry" = :list_of_cols_val_tab_del 
			
) 

       	 Then       
			error := 7;
         	error_message := 'Nota de telecomunicação deve ser modelo 21 ou modelo 22';  
	End If;
IF EXISTS(
	SELECT 
		1
		FROM "OPDN" T0
 		WHERE 
 		T0."CardCode" <> 'FOR0000116' AND 
 		T0."DiscPrcnt" <> 0 AND 
 		T0."DocEntry" = :list_of_cols_val_tab_del
   )
   THEN 
   		error := 7;
    	error_message := 'O desconto deve ser informado na linha'; 
 END IF;


END IF;
----------------------------------------------------------------------------------------------

IF :object_type = '24' and (:transaction_type = 'A' or :transaction_type = 'U') THEN
	IF EXISTS(
	SELECT
		1
	FROM ORCT AS py
	WHERE 
		EXISTS(SELECT 1 FROM ORCT t WHERE py."DocEntry" <> t."DocEntry" AND py."U_pix_reference" = t."U_pix_reference" AND "Canceled" = 'N')
		AND py."DocEntry" = :list_of_cols_val_tab_del
				
	) 
       	 Then       
			error := 88;
         	error_message := 'Esse codigo de pix ja recebeu pagamento';  
	End If;
END IF;


IF :object_type = '24' OR :object_type = '13' and (:transaction_type = 'U') THEN
	IF EXISTS(
	SELECT
		1
	FROM 
		ORCT AS py
		LEFT JOIN RCT2 p2 ON (py."DocEntry" = p2."DocNum")
		LEFT JOIN INV6 inst on(inst."DocEntry" = p2."DocEntry")
	WHERE
		py."U_pix_reference" <> inst."U_pix_reference" 
		AND py."Canceled" = 'N' AND (py."DocEntry" = :list_of_cols_val_tab_del OR inst."DocEntry" = :list_of_cols_val_tab_del)				
	) 
       	 Then       
			error := 88;
         	error_message := 'Pagamento pix nao esta consistente';  
	End If;
END IF;


IF :object_type = 'comissao' THEN
	IF NOT EXISTS(
		SELECT 
			1
		FROM "@COMISSAO" comi
		INNER JOIN "@CONDICOESFV" cond ON comi."Code" = cond."Code" AND 
		"U_prazo" IS NOT NULL
		WHERE cond."Code" = :list_of_cols_val_tab_del
	)	
		THEN 
				error := 7;
	         	error_message := 'Não pode comissão sem condição de pagamento'; 
	End If;
	
	IF EXISTS(
	SELECT
		1
	FROM
		"@CONDICOESFV" AS a	
	where
		exists(SELECT 1 FROM "@CONDICOESFV" AS b WHERE a."Code" = b."Code" and a."U_prazo" = b."U_prazo" and a."LineId" <> b."LineId")
	) 
		THEN
				error := 7;
	         	error_message := 'Não pode condição repetida'; 
	END IF;
END IF;

-----------------------------------------------------------------------------------------------------------
end;




