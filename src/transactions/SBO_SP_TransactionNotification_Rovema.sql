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
cardCode nvarchar(200);
pTblSuffix nvarchar(4);
query nvarchar(255);
debug nvarchar(200);
precoNota nvarchar(255);
precoEstoque nvarchar(255);
notaSemDespesa nvarchar(255);
itemCode nvarchar(255);
v_frete_sem_imp DECIMAL(15,2);
v_diff DECIMAL(15,2);
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
--------------------------------------------------------------------------------------------------------------
-- Nota Fiscal de Saida -- Andrew Ramires May 06/03/2023
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
	AND T0."U_venda_futura" IS null
	AND
	T0."DocEntry" = :list_of_cols_val_tab_del
	AND T0."CANCELED" = 'N'
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

IF EXISTS (
  SELECT 
  1
  FROM OINV 
  WHERE 
  OINV."Model" <> 54 
  AND OINV."CardCode" = 'CLI0003676'
  AND OINV."BPLId" = 11
  AND OINV."DocEntry" = :list_of_cols_val_tab_del
  AND OINV."SeqCode" <> 29
  
) THEN
	      
		error := 3;
    	error_message := 'Para emissão de NFC-e é permitido somente o CLI0003676 - Consumidor Final!'; 

end IF;

IF EXISTS (
  SELECT 
  1
  FROM OINV 
  WHERE 
  OINV."Model" <> 54 
  AND OINV."CardCode" = 'CLI0003695'
  AND OINV."BPLId" = 4 
  AND OINV."DocEntry" = :list_of_cols_val_tab_del
  AND OINV."SeqCode" <> 29
  
) THEN
	      
		error := 3;
    	error_message := 'Para emissão de NFC-e é permitido somente o CLI0003695 - Consumidor Final!'; 

end IF;

IF EXISTS (
  SELECT 
  1
  FROM OINV 
  WHERE 
  OINV."Model" <> 54 
  AND OINV."CardCode" = 'CLI0004114'
  AND OINV."BPLId" = 18
  AND OINV."DocEntry" = :list_of_cols_val_tab_del
  AND OINV."SeqCode" <> 29
  
) THEN
	      
		error := 3;
    	error_message := 'Para emissão de NFC-e é permitido somente o CLI0004114 - Consumidor Final!'; 

end IF;

IF EXISTS (
  SELECT 
  1
  FROM OINV 
  WHERE 
  OINV."Model" <> 54 
  AND OINV."CardCode" = 'CLI0004242'
  AND OINV."BPLId" = 17
  AND OINV."DocEntry" = :list_of_cols_val_tab_del
  AND OINV."SeqCode" <> 29
  
) THEN
	      
		error := 3;
    	error_message := 'Para emissão de NFC-e é permitido somente o CLI0004242 - Consumidor Final!'; 

end IF;

IF EXISTS(
SELECT 1 FROM OINV WHERE 
"SlpCode" = -1 
AND "BPLName" LIKE '%SUSTE%'
AND OINV."DocEntry"  = :list_of_cols_val_tab_del
AND OINV."Model" IN ('54','39')
) THEN 
		error := 7;
    	error_message :='Não pode venda sem vendedor!'; 


end IF;

IF EXISTS (
    SELECT 1
    FROM OINV
    WHERE
    "SeqCode" = -2
    AND "Model" = 57
    AND "DocEntry" = :list_of_cols_val_tab_del
    AND "CANCELED" <> 'Y'
    AND "Serial" IN (
    SELECT
        "Serial"
    FROM
        OINV
    WHERE
        "SeqCode" = -2
        AND "Model" = 57
        AND "CANCELED" <> 'Y'
    GROUP BY
        "Serial"
    HAVING
        COUNT(*) > 1
      )
) THEN
    error := 3;
    error_message := 'NUMERAÇÃO CT-E JÁ UTILIZADA!';
END IF;

IF EXISTS (
  SELECT 1
  FROM inv6
    INNER JOIN OINV n ON n."DocEntry"   = inv6."DocEntry"
    INNER JOIN OCTG c ON c."GroupNum"   = n."GroupNum"
  WHERE n."DocEntry"   = :list_of_cols_val_tab_del
    AND c."GroupNum"   <> -1   
    AND n."Model" = 39
  GROUP BY c."InstNum"
  HAVING COUNT(inv6."InstlmntID") <> c."InstNum"  
) THEN
  error         := 7;
  error_message := 'Número de parcelas diferente da condição de pagamento!';
END IF;
End If;
-----------------------------------------------------------------------------------------------
IF :object_type = '15' and ( :transaction_type = 'A') then
 IF NOT EXISTS (
	SELECT 1 FROM ODLN n
	INNER JOIN DLN1 l ON n."DocEntry" = l."DocEntry" 
	INNER JOIN OINV  M ON l."BaseEntry"  = M."DocEntry" 
	WHERE
	M."DocDate" <= TO_DATE('20230804', 'YYYYMMDD') 
	AND l."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN 
	
		
		IF  EXISTS(
			SELECT
				sum("U_TX_VlDeL") AS "soma",
				sum("U_TX_VlDeL")-n."DiscSum"
			FROM
				DLN4 t
				INNER JOIN ODLN n on(t."DocEntry" = n."DocEntry")
			WHERE 
				t."DocEntry" = :list_of_cols_val_tab_del
				AND t."staType" in(28,10)
				AND n."CANCELED" = 'N'
			GROUP BY 
				n."DiscSum",
				t."DocEntry"
			
			HAVING 
				(sum("U_TX_VlDeL")-n."DiscSum") >= 0.05 OR (sum("U_TX_VlDeL")-n."DiscSum") <= -0.05
			)
		THEN 
			error := 7;
			error_message:= 'Não permitido desconto divergente do valor do impoto desonerado';
		
	END IF;
	
END IF;

  IF EXISTS(
	SELECT 
		1
		FROM ODLN T0
		INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry"
 		WHERE 
 		T1."Usage" <> 17 AND
 		NOT T0."DiscSumSy" BETWEEN -0.05 AND 0.05 AND 
 		T0."CANCELED" = 'N'
 		AND T0."DocEntry" = :list_of_cols_val_tab_del
   )
   THEN 
   		error := 7;
    	error_message := 'Desconto não permitido'; 
   END IF;
	IF EXISTS (
		Select
			1
		from ODLN T0
		INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry" 
		
		WHERE 
		T1."Price" <= 0
		AND T1."Usage" <> 112
		AND T0."DocEntry" = :list_of_cols_val_tab_del
		AND T0."CANCELED" = 'N'
		)
		THEN
		      
			error := 7;
	    	error_message := 'Informar preço unitario'; 
	END IF;
 IF EXISTS(
 	SELECT 
 	1
 	FROM ODLN T0
 	WHERE
 	T0."CardCode" = 'CLI0003676'
 	AND T0."DocEntry" = :list_of_cols_val_tab_del
 )
 THEN
		      
			error := 7;
	    	error_message := 'Não pode entregar para consumidor final'; 
	END IF;


 IF EXISTS(
	SELECT 
1
	FROM 
	ODLN N
	INNER JOIN DLN1 L ON N."DocEntry" = L."DocEntry" 
	INNER JOIN OITW D ON D."ItemCode" = L."ItemCode" AND D."WhsCode" = L."WhsCode" 
	WHERE L."Usage" IN (5,110)
	AND ROUND(L."INMPrice",2) <> ROUND(D."AvgPrice",2) 
	AND N.CANCELED = 'N'
	AND N."DocEntry" = :list_of_cols_val_tab_del
	LIMIT 1
)
THEN
SELECT 
	L."ItemCode",
	ROUND(L."INMPrice",2),
	ROUND(D."AvgPrice",2) 
	INTO itemCode,precoNota,precoEstoque
	FROM 
	ODLN N
	INNER JOIN DLN1 L ON N."DocEntry" = L."DocEntry" 
	INNER JOIN OITW D ON D."ItemCode" = L."ItemCode" AND D."WhsCode" = L."WhsCode" 
	WHERE L."Usage" IN (5,110)
	AND ROUND(L."INMPrice",2) <> ROUND(D."AvgPrice",2) 
	AND N.CANCELED = 'N'
	AND N."DocEntry" = :list_of_cols_val_tab_del
	LIMIT 1;
	
			error := 7;
	    	error_message := 'Preço unitario diferente do estoque ' || 'Item: ' || itemcode || 'preco nota ' || precoNota || ' preco estoque ' || precoEstoque; 
 END IF;
			IF EXISTS (
    SELECT 
        1
    FROM 
        (
            SELECT
                "DocEntry",
                SUM("LineTotal") AS frete
            FROM 
                DLN13
            GROUP BY 
                "DocEntry"
        ) AS FRETE
    INNER JOIN 
        (
            SELECT
                "DocEntry",
                "TotalExpns"
            FROM
                ODLN
            WHERE
                "CANCELED" = 'N'
                AND "DocEntry" = :list_of_cols_val_tab_del
        ) AS NOTA
    ON 
        FRETE."DocEntry" = NOTA."DocEntry"
    WHERE 
        FRETE.frete <> NOTA."TotalExpns"
)
THEN
    error := 7;
    error_message := 'Diferença entre frete e total de despesas encontrada.';
END IF;
  IF EXISTS (
       SELECT 1
        FROM V_FAT_ENTREGA_DIFERENCAS V
        JOIN DLN1 D ON D."BaseEntry" = V."DocEntry"
        WHERE D."DocEntry" = :list_of_cols_val_tab_del
          AND (
              V."DIFTOTAL" < -1 OR
              V."DIFFRETE" < -1
          )
          LIMIT 1
          
    )
    THEN
        error:= 7;
        error_message:= 'Nota com valor maior que o da mãe!';
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
		T0."CANCELED" = 'N' AND 
		T1."Usage" NOT in(100,16,54,67) AND  
		T0."DocEntry" = :list_of_cols_val_tab_del
		)
		THEN
		      
			error := 7;
	    	error_message := 'Trocar para o depósito para o 500.05';  
		END if;

	IF  EXISTS (
	SELECT 1
    FROM orin
    WHERE 
	    ORIN."CANCELED" = 'N'
	   AND (NOT  EXISTS (
	        SELECT 1 
	        FROM RIN1 
	        WHERE RIN1."DocEntry" = :list_of_cols_val_tab_del
	          AND RIN1."BaseEntry"  IS NOT NULL
    )
    and 
    NOT EXISTS (
    SELECT 1 FROM 
    RIN21 WHERE RIN21."DocEntry" = :list_of_cols_val_tab_del
    ))
    
    AND "DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
		error := 7;
    	error_message := 'Colocar referencia da nota';  
	END if;
	IF EXISTS(
		SELECT 
		1
		FROM ORIN T0
		INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"
		INNER JOIN OUSG T2 ON T1."Usage" = T2."ID"
		WHERE 
		("U_TX_NatOp"  IS NULL OR "U_TX_NatOp" = '') 
		AND T0."DocEntry" = :list_of_cols_val_tab_del
		AND T0."Model" = 39 
	)
	THEN 
	error := 7;
	error_message := 'Favor colocar natureza de operação';
 END IF;
IF EXISTS (
	Select
		1
	from ORIN T0
	INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry" 
	
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
END if;

---------------------------------------------------------------------------------------
if  :object_type = '19' and (:transaction_type = 'A') THEN

	IF NOT EXISTS (
	SELECT 1 FROM ORPC 
     INNER JOIN RPC21 ON ORPC."DocEntry" = RPC21."DocEntry"
     WHERE 
     RPC21."DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
		error := 7;
		error_message := 'Colocar referencia da nota';  
	END if;
	IF EXISTS(
		SELECT 
		1
		FROM ORPC T0
		INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
		INNER JOIN OUSG T2 ON T1."Usage" = T2."ID"
		WHERE 
		("U_TX_NatOp"  IS NULL OR "U_TX_NatOp" = '' OR "U_TX_NatOp" <> 'DEVOLUÇÃO DE ' || T2."Descr") 
		AND T0."DocEntry" = :list_of_cols_val_tab_del
		AND T0."Model" = 39 
	)
	THEN 
	error := 7;
	error_message := 'Favor colocar natureza de operação';
 END IF;
END if;
-----------------------------------------------------------------------------------------
if  :object_type = '16' and (:transaction_type = 'A'or :transaction_type = 'U') THEN

	IF  EXISTS (
	SELECT 1
    FROM ORDN
    WHERE 
	    ORDN."CANCELED" = 'N'
	   AND (NOT  EXISTS (
	        SELECT 1 
	        FROM RDN1 
	        WHERE RDN1."DocEntry" = :list_of_cols_val_tab_del
	          AND RDN1."BaseEntry"  IS NOT NULL
    )
    and 
    NOT EXISTS (
    SELECT 1 FROM 
    RDN21 WHERE RDN21."DocEntry" = :list_of_cols_val_tab_del
    ))
    
    AND "DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
		error := 7;
    	error_message := 'Colocar referencia da nota';  
	END if;
	IF EXISTS(
		SELECT 
		1
		FROM ORDN T0
		INNER JOIN RDN1 T1 ON T0."DocEntry" = T1."DocEntry"
		INNER JOIN OUSG T2 ON T1."Usage" = T2."ID"
		WHERE 
		("U_TX_NatOp"  IS NULL OR "U_TX_NatOp" = '' OR "U_TX_NatOp" <> 'DEVOLUÇÃO DE ' || T2."Descr") 
		AND T0."DocEntry" = :list_of_cols_val_tab_del
		AND T0."Model" = 39 
	)
	THEN 
	error := 7;
	error_message := 'Favor colocar natureza de operação';
 END IF;
END if;
----------------------------------------------------------------------------------------
if  :object_type = '21' and (:transaction_type = 'A') THEN

	IF  EXISTS (
	SELECT 1
    FROM ORPD
    WHERE 
	    ORPD."CANCELED" = 'N'
	   AND (NOT  EXISTS (
	        SELECT 1 
	        FROM RPD1 
	        WHERE RPD1."DocEntry" = :list_of_cols_val_tab_del
	          AND RPD1."BaseEntry"  IS NOT NULL
    )
    and 
    NOT EXISTS (
    SELECT 1 FROM 
    RPD21 WHERE RPD21."DocEntry" = :list_of_cols_val_tab_del
    ))
    
    AND "DocEntry" = :list_of_cols_val_tab_del
	)
	THEN
		error := 7;
    	error_message := 'Colocar referencia da nota';  
	END if;
	IF EXISTS(
		SELECT 
		1
		FROM ORPD T0
		INNER JOIN RPD1 T1 ON T0."DocEntry" = T1."DocEntry"
		INNER JOIN OUSG T2 ON T1."Usage" = T2."ID"
		WHERE 
		("U_TX_NatOp"  IS NULL OR "U_TX_NatOp" = '' OR "U_TX_NatOp" <> 'DEVOLUÇÃO DE ' || T2."Descr") 
		AND T0."DocEntry" = :list_of_cols_val_tab_del
		AND T0."Model" = 39 
	)
	THEN 
	error := 7;
	error_message := 'Favor colocar natureza de operação';
 END IF;
END if;
----------------------------------------------------------------------------------------
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
	AND T0."CANCELED" = 'N'
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
			T1."Usage" NOT IN(14,34,24,33,73,74,36,13,72,65,122,64,69,67,39,136) AND 
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
			T1."Usage" NOT IN(14,34,24,33,73,74,36,13,72,65,122,64,69,67,39,136) AND 
			T0."Model" <> 39 AND 
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
 IF EXISTS(
	Select 
		1
		From OPCH T0
		Where 
			T0."DocEntry" = :list_of_cols_val_tab_del and T0."CANCELED" = 'N' And 
			EXISTS(Select T10."DocEntry" From OPCH T10 
					Where T10."DocEntry" <> T0."DocEntry" And T10."Serial" = T0."Serial" 
					And T10."CardCode" = T0."CardCode"
					AND T10."CardName" = T0."CardName"
					And T10."Model" = T0."Model"
				And T10."SeriesStr" = T0."SeriesStr"
					and T10."CANCELED" = 'N'
					UNION 
					Select T10."DocEntry" From OPDN T10 
					Where T10."DocEntry" <> T0."DocEntry" And T10."Serial" = T0."Serial" 
					And T10."CardCode" = T0."CardCode"
					AND T10."CardName" = T0."CardName"
					And T10."Model" = T0."Model"
				And T10."SeriesStr" = T0."SeriesStr"
					and T10."CANCELED" = 'N'
					
					)
			)
		 
		THEN        
			error := 1;
         	error_message := 'Documento nota fiscal já existe';  
		
         
  End if;
 
IF EXISTS(
SELECT
		1
		From "OPCH" T0	
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
		Where 
			T1."Usage" IN(33,65) AND 
			T0."Model" <> 37 AND 
			T0."SeqCode" = '-2' AND
			T0."CANCELED" = 'N' AND
			T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Favor Mudar para modelo outras';  
	End If;
  IF EXISTS(
SELECT
		1
		From "OPCH" T0
		INNER JOIN PCH12 ON T0."DocEntry" = PCH12."DocEntry" 
		Where 
			T0."Model" = 39 AND 
			T0."CANCELED" = 'N' 
			AND (PCH12."Incoterms" IS NULL OR NOT PCH12."Incoterms" in(0,1,2,3,4,9))  
			AND T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Favor preencher incoterms corretamente';  
	End If;

IF EXISTS(
SELECT
	1
FROM 
	OPCH T0 
	INNER JOIN OCRD pn ON pn."CardCode" = T0."CardCode"
	INNER JOIN CRD11 idf ON pn."CardCode" = idf."CardCode"
	INNER JOIN PCH1 li ON T0."DocEntry" = li."DocEntry" 
	INNER JOIN OITM it ON li."ItemCode" = it."ItemCode" 
WHERE

	T0."Model" = 39
	AND T0."CANCELED" = 'N'
	AND (idf."TributType" IN (14,15,16,17,19) OR idf."TributType" = 11 AND pn."U_LBR_FOLHA_PGTO" = 'COM')
	AND T0."DocEntry" = :list_of_cols_val_tab_del
	
	AND 
	(
		(pn."U_TX_RF_IPre" = '' OR pn."U_TX_RF_IPre" IS null OR pn."U_TX_RF_IsTrFolha" = '' OR pn."U_TX_RF_IsTrFolha" IS NULL)
	--	OR (it."U_TX_CodNatRend" = '' OR it."U_TX_CodNatRend" IS NULL )
		OR (T0."U_TX_RF_TObr" = '' OR T0."U_TX_RF_TObr" IS NULL 
			OR T0."U_TX_RF_TRep" = '' OR T0."U_TX_RF_TRep" IS NULL
			OR T0."U_TX_RF_IAquis" = '' OR T0."U_TX_RF_IAquis" IS NULL)
	)
	)
	THEN 
		error := 7;
        error_message := 'Favor preencher campos da Reinf na nota ou no parceiro ou no item ou no modelo.'; 
   END IF;
  
----TRAVA CAMPOS Codigo de imposto /  CFOP / CST ICMS / CST PIS / CST COFINS
IF EXISTS(
SELECT
	1
FROM "OPCH" FE 
	INNER JOIN "PCH1" NF ON  NF."DocEntry" = FE."DocEntry" 
	
WHERE FE."CardCode" LIKE ('FOR%')
AND (NF."CFOPCode" = '' OR NF."CFOPCode" IS NULL
AND NF."CSTCode" = '' OR NF."CSTCode" IS NULL
AND NF."CSTfPIS" = '' OR NF."CSTfPIS" IS NULL
AND NF."CSTfCOFINS" = '' OR NF."CSTfCOFINS" IS NULL)
AND NF."DocEntry" = :list_of_cols_val_tab_del

)

Then       
			error := 3;
         	error_message := 'Campos CFOP / CST ICMS / CST PIS / CST COFINS é obrigatório!';
         
END IF;

---TRAVA QUANDO SELECIONAR AS DUAS UTILIZAÇÕES, OBRIGAR O MODELO DE NF SER - OUTRA.
IF EXISTS(
SELECT
		1
		From "OPCH" T0		
		INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
		Where 
			T1."Usage" IN (122,64,136) AND
			T0."Model" <> 37 AND
			T0."CANCELED" = 'N' AND
		    T0."DocEntry" = :list_of_cols_val_tab_del
)
       	 Then       
			error := 3;
         	error_message := 'Para utilização - CARTÃO VISA BRADESCO, CARTÃO VISA BRASIL e CARTÃO ELO BRASIL recomenda-se usar modelo de NF - OUTRA';  
End If;

---TRAVA QUANDO A NOTA DE ENTRADA CONTER DESONERAÇÃO OBRIGAR O ITEM ESTÁ SELECIONADO A FLAG SUJEITO A RETENÇÃO E NO CAMPO CONVENIO 100 ESTÁ SIM.
IF EXISTS(
SELECT 
	1
	FROM PCH1 ne
    INNER JOIN OITM i  ON i."ItemCode" = ne."ItemCode"
    INNER JOIN OUSG u  ON u."ID" = ne."Usage" 	
    WHERE
        ne."TaxCode" = '1101-018'
        AND i."U_ROV_CONVENIO" <> 'SIM ' 
        AND i."WTLiable" = 'N'
        AND ne."DocEntry" = :list_of_cols_val_tab_del
)
	Then       
			error := 3;
         	error_message := 'A Nota de Entrada contém desoneração, verificar no cadastro do item as informações SUJEITO A RETENÇÃO DE IMPOSTO e CONVENIO 100';  
	End If;

IF EXISTS(
SELECT 
	1
	FROM PCH1 ne
    INNER JOIN OITM i  ON i."ItemCode" = ne."ItemCode"
    INNER JOIN OUSG u  ON u."ID" = ne."Usage" 	
    WHERE
        ne."TaxCode" <> '1101-018'
        AND i."U_ROV_CONVENIO" = 'SIM '
        AND i."WTLiable" = 'Y'
        AND ne."DocEntry" = :list_of_cols_val_tab_del
    
)
    Then       
			error := 3;
         	error_message := 'A Nota de Entrada não contém desoneração, verificar no cadastro do item as informações SUJEITO A RETENÇÃO DE IMPOSTO e CONVENIO 100';  
	End If;

IF EXISTS(
SELECT 1 FROM 
OPCH NOTA
INNER JOIN PCH1 p ON NOTA."DocEntry" = P."DocEntry" 
INNER JOIN STC1 imposto ON imposto."STCCode" = p."TaxCode"  AND IMPOSTO."STAType" = 19
WHERE 
P."DocEntry" = :list_of_cols_val_tab_del 
AND NOTA."CANCELED" = 'N'
AND NOTA."Model" NOT IN (37,38) 
AND P."CSTfPIS" <> IMPOSTO."CstCodeIn"
)
  Then       
			error := 7;
         	error_message := 'O CST do PIS não corresponde ao código do imposto.';  
	End If;

IF EXISTS(
SELECT 1 FROM 
OPCH NOTA
INNER JOIN PCH1 p ON NOTA."DocEntry" = P."DocEntry" 
LEFT JOIN STC1 imposto ON imposto."STCCode" = p."TaxCode"  AND IMPOSTO."STAType" = 21
WHERE 
P."DocEntry" = :list_of_cols_val_tab_del 
AND NOTA."CANCELED" = 'N'
AND NOTA."Model" NOT IN (37,38) 
AND P."CSTfCOFINS" <> IMPOSTO."CstCodeIn"
)
  Then       
			error := 7;
         	error_message := 'O CST do COFINS não corresponde ao código do imposto.';  
	End If;


-----------------------------------------------------------------------------------------------



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
	AND T0."CANCELED" = 'N'
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
			T1."Usage" NOT IN(14,34,24,33,73,74,36,13,72,128) AND 
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
  IF EXISTS(
	Select 
		1
		From OPDN T0
		Where 
			T0."DocEntry" = :list_of_cols_val_tab_del and T0."CANCELED" = 'N' And 
			EXISTS(Select T10."DocEntry" From OPDN T10 
					Where T10."DocEntry" <> T0."DocEntry" And T10."Serial" = T0."Serial" 
					And T10."CardCode" = T0."CardCode"
					AND T10."CardName" = T0."CardName"
					And T10."Model" = T0."Model"
				And T10."SeriesStr" = T0."SeriesStr"
					and T10."CANCELED" = 'N'
					UNION 
					Select T10."DocEntry" From OPCH T10 
					Where T10."DocEntry" <> T0."DocEntry" And T10."Serial" = T0."Serial" 
					And T10."CardCode" = T0."CardCode"
					AND T10."CardName" = T0."CardName"
					And T10."Model" = T0."Model"
				And T10."SeriesStr" = T0."SeriesStr"
					and T10."CANCELED" = 'N')
			)
		 
		THEN        
			error := 1;
         	error_message := 'Documento nota fiscal já existe';  
		
         
  End if;
 IF EXISTS(
SELECT
		1
		From "OPDN" T0	
		INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry"
		Where 
			T1."Usage" = 47
			AND T0."CardCode" in('FOR0000352','FOR0001351','FOR0002166') 
			AND T0."CANCELED" = 'N'
			AND T1."WhsCode" <> '500.05'
			AND T0."BPLId" = 2
			AND T0."DocEntry" = :list_of_cols_val_tab_del
			)
		THEN
			error := 1;
         	error_message := 'Favor trocar para o depósito 500.05';
   END IF;
  
  IF EXISTS(
  SELECT 
    1  
     FROM OPDN t0 
	INNER JOIN PDN1 IT ON t0."DocEntry" = IT."DocEntry" 
	WHERE t0."DocEntry" = :list_of_cols_val_tab_del 
		AND IT."Usage" IN (104,59,58,25,115,110,47)  
		AND t0."U_ChaveAcesso" = (SELECT P."KeyNfe" FROM ODLN NF INNER JOIN "Process" P ON NF."DocEntry" = P."DocEntry" AND P."DocType" = NF."ObjType" WHERE P."KeyNfe" = t0."U_ChaveAcesso")
	GROUP BY T0."U_ChaveAcesso",T0."DocNum" 
	HAVING 
		SUM(IT."LineTotal") <> 
		(SELECT SUM(IT2."LineTotal")  FROM ODLN NF INNER JOIN "Process" P ON NF."DocEntry" = P."DocEntry" AND P."DocType" = NF."ObjType" INNER JOIN DLN1 IT2 ON NF."DocEntry" = IT2."DocEntry"  WHERE P."KeyNfe" = t0."U_ChaveAcesso" 
	GROUP BY NF."DocEntry"))

	THEN 
		error := 8;
		error_message := 'Entrada com valor divergente da Nota de Saída!'; 
END IF;
IF EXISTS(
SELECT 1 FROM 
OPDN NOTA
INNER JOIN PDN1 p ON NOTA."DocEntry" = P."DocEntry" 
INNER JOIN STC1 imposto ON imposto."STCCode" = p."TaxCode"  AND IMPOSTO."STAType" = 19
WHERE 
P."DocEntry" = :list_of_cols_val_tab_del 
AND NOTA."CANCELED" = 'N'
AND P."Usage" <> 19
AND NOTA."Model" NOT IN (37,38) 
AND P."CSTfPIS" <> IMPOSTO."CstCodeIn"
)
  Then       
			error := 7;
         	error_message := 'O CST do PIS não corresponde ao código do imposto.';  
	End If;

IF EXISTS(
SELECT 1 FROM 
OPDN NOTA
INNER JOIN PDN1 p ON NOTA."DocEntry" = P."DocEntry" 
LEFT JOIN STC1 imposto ON imposto."STCCode" = p."TaxCode"  AND IMPOSTO."STAType" = 21
WHERE 
P."DocEntry" = :list_of_cols_val_tab_del 
AND NOTA."CANCELED" = 'N'
AND P."Usage" <> 19
AND NOTA."Model" NOT IN (37,38) 
AND P."CSTfCOFINS" <> IMPOSTO."CstCodeIn"
)
  Then       
			error := 7;
         	error_message := 'O CST do COFINS não corresponde ao código do imposto.';  
	End If;
IF EXISTS(
WITH
CUSTO_NOTA AS (
    SELECT
        OPDN."DocEntry",
        OPDN."DocNum",
        OPDN."DocDate",
        OPDN."BPLId",
        OPDN."Serial",
        PDN1."ItemCode",
        PDN1."InvQty",
        (PDN1."Quantity" * PDN1."Price") - SUM(PDN4."TaxSum") AS VALOR_TRANSACAO,
        ((PDN1."Quantity" * PDN1."Price") - SUM(PDN4."TaxSum")) / NULLIF(PDN1."InvQty", 0) AS CUSTO_QUE_ENTRA,
        PDN1."WhsCode"
    FROM
        PDN1
    INNER JOIN OPDN ON OPDN."DocEntry" = PDN1."DocEntry"
    INNER JOIN PDN4 ON PDN1."DocEntry" = PDN4."DocEntry"
        AND PDN1."LineNum" = PDN4."LineNum"
    WHERE
        PDN1."DocEntry" = :list_of_cols_val_tab_del
        AND OPDN."CANCELED" = 'N'
        AND PDN1."Usage" = 19
        AND OPDN."Model" = 39
        AND PDN1."ItemCode" NOT IN ('INS0000136')
    GROUP BY
        OPDN."DocEntry",
        PDN1."ItemCode",
        PDN1."InvQty",
        PDN1."Quantity",
        PDN1."Price",
        PDN1."WhsCode",
        OPDN."DocNum",
        OPDN."BPLId",
        OPDN."Serial",
        OPDN."DocDate"
),

TRANSACOES AS (
    SELECT
        ESTOQUE."TransValue",
        ESTOQUE."InQty" - ESTOQUE."OutQty" AS "InQty",
        ESTOQUE."ItemCode",
        ESTOQUE."Warehouse",
        ROW_NUMBER() OVER (PARTITION BY ESTOQUE."ItemCode"
            ORDER BY ESTOQUE."TransNum" DESC) AS RowNum
    FROM
        OINM ESTOQUE
    INNER JOIN CUSTO_NOTA ON ESTOQUE."ItemCode" = CUSTO_NOTA."ItemCode"
        AND ESTOQUE."Warehouse" = CUSTO_NOTA."WhsCode"
),

CUSTO_MEDIO AS (
    SELECT 
        "ItemCode",
        "Warehouse",
        SUM("TransValue") AS VALOR,
        SUM("InQty") AS QUANTIDADE
    FROM TRANSACOES
    WHERE RowNum >= 2
    GROUP BY "ItemCode", "Warehouse"
),

VARIACAO_CUSTO AS (
    SELECT
        NOTA."DocEntry",
        NOTA."DocDate",
        NOTA."DocNum",
        NOTA."BPLId",
        NOTA."Serial",
        NOTA."ItemCode",
        NOTA."WhsCode",
        CASE
            WHEN ESTOQUE.QUANTIDADE <> 0 
            THEN ESTOQUE.VALOR / ESTOQUE.QUANTIDADE
            ELSE 0
        END AS CUSTO_MEDIO,
        CASE
            WHEN ESTOQUE.QUANTIDADE <> 0 AND ESTOQUE.VALOR <> 0 
            THEN ((NOTA.CUSTO_QUE_ENTRA - (ESTOQUE.VALOR / ESTOQUE.QUANTIDADE)) / (ESTOQUE.VALOR / ESTOQUE.QUANTIDADE)) * 100
            ELSE 0
        END AS VARIACAO,
        NOTA.CUSTO_QUE_ENTRA
    FROM
        CUSTO_MEDIO ESTOQUE
    INNER JOIN CUSTO_NOTA NOTA 
        ON NOTA."ItemCode" = ESTOQUE."ItemCode"
        AND NOTA."WhsCode" = ESTOQUE."Warehouse"
    WHERE
        NOTA."ItemCode" LIKE 'INS%'
        AND NOTA."BPLId" = 2
        AND NOTA."DocDate" >= '20240101'
)

SELECT *
FROM VARIACAO_CUSTO
WHERE VARIACAO > 50 OR VARIACAO < -50

) THEN
        error := 7;

error_message := 'Desvio de custo muito alto!';
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
	
	IF  EXISTS(
	WITH 
	condicoes AS (
	SELECT o."GroupNum"  FROM OCTG o WHERE "U_Rov_EnviarForca" = '2'
	)
	SELECT * FROM "@CONDICOESFV" 
	INNER JOIN condicoes ON condicoes."GroupNum" = "@CONDICOESFV" ."U_prazo" 
	WHERE "Code" = :list_of_cols_val_tab_del
	)	
		THEN 
				error := 7;
	         	error_message := 'Essa condição de pagamento não esta liberada.'; 
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

IF  :object_type = '23' AND (:transaction_type = 'U' OR :transaction_type = 'A') then
 IF  EXISTS(
	SELECT
		sum("U_TX_VlDeL") AS "soma",
		sum("U_TX_VlDeL")-n."DiscSum"
	FROM
		QUT4 t
		INNER JOIN OQUT n on(t."DocEntry" = n."DocEntry")
	WHERE 
		t."DocEntry" = :list_of_cols_val_tab_del
		AND t."staType" in(28,10) 
	GROUP BY 
		n."DiscSum",
		t."DocEntry",
		"U_pedido_update",
		n."UserSign"
	HAVING 
		((sum("U_TX_VlDeL")-n."DiscSum") >= 0.05 OR (sum("U_TX_VlDeL")-n."DiscSum") <= -0.05) AND  ("U_pedido_update" = '0' AND n."UserSign" <> 162)
	)
		THEN 
		error := 7;
		error_message:= 'Não permitido desconto divergente do valor do impoto desonerado';
	END IF;
 IF exists(
	SELECT 
		1
	FROM 
		QUT1 C
		INNER JOIN OQUT o ON C."DocEntry" = o."DocEntry"
		LEFT JOIN OPLN LP ON C."U_idTabela" = LP."ListNum"
	WHERE
	o."U_venda_futura" IS null
	AND ("U_preco_negociado" = 0 
	OR C."U_idTabela" IS NULL OR LP."U_publica_forca" = 0 OR LP."U_tipoComissao" IS NULL )
	AND c."DocEntry"  = :list_of_cols_val_tab_del
	)
	THEN 
	error := 7;
	error_message:= 'Favor preecher campo id tabela valido de preço e preço negociado';
  END IF;
    IF EXISTS(
	SELECT 
	1
	FROM
	OQUT T0
	INNER JOIN QUT1 T1 ON T0."DocEntry" = T1."DocEntry" 
	 WHERE T1."U_preco_base"  <= 0 
	 AND T0."BPLName" LIKE 'SUSTENNUTRI%'
	AND T0."DocEntry" = :list_of_cols_val_tab_del
)
 THEN
		      
	error := 7;
	error_message := 'O preço base não pode ser 0, favor veficiar o preço na tabela'; 
	END IF;
 END IF;
-------------------------PEDIDO DE VENDA------------------------------------------
IF  :object_type = '17' and (:transaction_type = 'A' OR :transaction_type = 'U') then
	
 IF  EXISTS(
	SELECT
		sum("U_TX_VlDeL") AS "soma",
		sum("U_TX_VlDeL")-n."DiscSum"
	FROM
		RDR4 t
		INNER JOIN ORDR n on(t."DocEntry" = n."DocEntry")
	WHERE 
		t."DocEntry" = :list_of_cols_val_tab_del
		AND t."staType" in(28)
		AND n."CANCELED" = 'N'
	GROUP BY 
		n."DiscSum",
		t."DocEntry",
		n."UserSign",
		"U_pedido_update"
	
	HAVING 
			((sum("U_TX_VlDeL")-n."DiscSum") >= 0.05 OR (sum("U_TX_VlDeL")-n."DiscSum") <= -0.05) AND  ("U_pedido_update" = '0' AND n."UserSign" <> 162)
	)
		THEN 
		error := 7;
		error_message:= 'Não permitido desconto divergente do valor do impoto desonerado';
	END IF;
  IF EXISTS(
	SELECT 
		1
		FROM ORDR T0
		INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
 		WHERE 
 		T0."U_venda_futura" IS null
 		AND T1."Usage" <> 16 AND
 		NOT T0."DiscSumSy" BETWEEN -0.05 AND 0.05 AND  
 		T0."CANCELED" = 'N'
 		AND T0."DocEntry" = :list_of_cols_val_tab_del
 		
   )
   THEN 
   		error := 7;
    	error_message := 'Desconto não permitido'; 
   END IF;
  IF exists(
		SELECT 
		1
	FROM ORDR T0
		INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
		LEFT JOIN OPLN LP ON T1."U_idTabela" = LP."ListNum"
	WHERE 
	T0."U_venda_futura" IS null
	AND (T1."U_preco_negociado" = 0 
	OR T1."U_idTabela" IS NULL OR LP."U_publica_forca" = 0 OR 	LP."U_tipoComissao" IS NULL )
	AND T0."BPLName" LIKE 'SUSTENNUTRI%'
	AND T0."DocEntry"  = :list_of_cols_val_tab_del
	)
	THEN 
	error := 7;
	error_message:= 'Favor preecher campo id tabela de preço valido e preço negociado';
  END IF;
   IF EXISTS(
	SELECT 
	1
	FROM
	ORDR T0
	INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
	 WHERE T1."U_preco_base"  <= 0 
	 AND T0."BPLName" LIKE 'SUSTENNUTRI%'
	AND  T0."DocEntry" = :list_of_cols_val_tab_del
)
 THEN
		      
	error := 7;
	error_message := 'O preço base não pode ser 0, favor veficiar o preço na tabela'; 
	END IF;
	
IF EXISTS (
  SELECT 1
  FROM "ORDR" o
  JOIN OCTG c
    ON c."GroupNum" = o."GroupNum"
   AND c."U_Rov_EnviarForca" = '2'    
  WHERE o."DocEntry" = :list_of_cols_val_tab_del
    AND o."CANCELED"  = 'N'
) THEN
  error         := 7;
  error_message := 'Essa condição de pagamento não está liberada.';
END IF;
  IF EXISTS(
	SELECT 1 FROM ORDR
	WHERE  NOT EXISTS(
	SELECT 1 FROM  WTM1 WHERE "UserID"  = ORDR."UserSign" AND "WtmCode" = 26)
	AND "DocEntry" = :list_of_cols_val_tab_del
	AND ORDR."UserSign" NOT IN (1)
	)
	THEN 
	   error := 7;
	   error_message := 'Voce não esta na alçada de credito, favor entrar em contato com a TI';
	END IF;
END IF;
IF :object_type = '13' and (:transaction_type = 'A') then 
  IF EXISTS(
	SELECT 
		1
		FROM OINV T0
		INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
 		WHERE 
 		T0."U_venda_futura" IS null
 		AND T1."Usage" <> 16 AND
 	    NOT T0."DiscSumSy" BETWEEN -0.05 AND 0.05 AND  
 		T0."CANCELED" = 'N'
 		AND T0."DocEntry" = :list_of_cols_val_tab_del
 		
   )
   THEN 
   		error := 7;
    	error_message := 'Desconto não permitido'; 
   END IF;
 IF EXISTS(
	SELECT
		sum("U_TX_VlDeL") AS "soma",
		sum("U_TX_VlDeL")-n."DiscSum"
	FROM
		INV4 t
		INNER JOIN OINV n on(t."DocEntry" = n."DocEntry")
	WHERE 
		t."DocEntry" = :list_of_cols_val_tab_del
		AND t."staType" in(28,10)
		AND n."CANCELED" = 'N'
	GROUP BY 
		n."DiscSum",
		t."DocEntry"
		
	HAVING 
		(sum("U_TX_VlDeL")-n."DiscSum") >= 0.05 OR (sum("U_TX_VlDeL")-n."DiscSum") <= -0.05
	)
		THEN 
		error := 7;
		error_message:= 'Não permitido desconto divergente do valor do impoto desonerado';
	END IF;
 IF EXISTS(
 	SELECT 
 	1
 	FROM OINV T0
 	INNER JOIN INV1 i ON T0."DocEntry" = i."DocEntry" 
 	WHERE
 	i."Usage" <> 9
 	AND T0."Model" = 54
 	AND T0."DocEntry" = :list_of_cols_val_tab_del
 )
 THEN
		      
			error := 7;
	    	error_message := 'Favor trocar utilização ou modelo para nfe'; 
	END IF;
 IF EXISTS(
 	SELECT 
 	1
 	FROM OINV T0
 	INNER JOIN INV1 i ON T0."DocEntry" = i."DocEntry" 
 	WHERE
 	T0."CardCode" = 'CLI0003676'
 	AND T0."Model" NOT IN(54,37)
 	AND T0."DocEntry" = :list_of_cols_val_tab_del
 )
 THEN
		      
			error := 7;
	    	error_message := 'Favor trocar colocar cupom fiscal'; 
	END IF;
 IF EXISTS(
 	SELECT 
 	1
 	FROM OINV T0
 	INNER JOIN INV3 i ON T0."DocEntry" = i."DocEntry" 
 	WHERE
 	T0."Model" = 54
 	AND i."LineTotal" <> 0
 	AND T0."DocEntry" = :list_of_cols_val_tab_del
 )
 THEN
		      
			error := 7;
	    	error_message := 'Não pode frete no cupom fiscal'; 
	END IF;

  IF EXISTS(
SELECT
		1
		From "OINV" T0
		INNER JOIN INV12 ON T0."DocEntry" = INV12."DocEntry" 
		Where 
			T0."Model" = 54 AND 
			T0."CANCELED" = 'N' 
			AND INV12."Incoterms" <> 9
			AND T0."DocEntry" = :list_of_cols_val_tab_del
			
) 

       	 Then       
			error := 7;
         	error_message := 'Favor preencher incoterms corretamente';  
End If;

IF EXISTS(	
SELECT
	1
FROM 
	OINV T0 
	INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN OCRD pn ON pn."CardCode" = T0."CardCode"
	INNER JOIN OITM it ON T1."ItemCode" = it."ItemCode" 
WHERE
	T1."Usage" IN (66,68,67) -- tenta trocar isso por cfop, coloca na clausua ON do INNER assim ja elimina tudo
	AND T0."Model" = 39
	AND T0."CANCELED" = 'N'
	AND T0."DocEntry" = :list_of_cols_val_tab_del
	AND 
	(
	-- Parceiro tem os campos preenchido?
		(pn."U_TX_RF_IPre" = '' OR pn."U_TX_RF_IPre" IS null OR pn."U_TX_RF_IsTrFolha" = '' OR pn."U_TX_RF_IsTrFolha" IS NULL)
		--OR (it."U_TX_CodNatRend" = '' OR it."U_TX_CodNatRend" IS NULL )
	-- Verifica campos nota fiscal?
		OR (T0."U_TX_RF_TObr" = '' OR T0."U_TX_RF_TObr" IS NULL 
			OR T0."U_TX_RF_TRep" = '' OR T0."U_TX_RF_TRep" IS NULL
			OR T0."U_TX_RF_ICom" = '' OR T0."U_TX_RF_ICom" IS NULL
			OR T0."U_TX_RF_IAquis" = '' OR T0."U_TX_RF_IAquis" IS NULL)
	)
	)
	THEN
			error := 7;
	    	error_message := 'Favor preencher campos da REINF na nota ou no parceiro ou no item'; 
	 END IF;
	
	  IF EXISTS(
	SELECT 
	1
	FROM
	OINV T0
	INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
	WHERE T1."U_preco_base"  <= 0
	AND T0."BPLName" LIKE '%SUSTE%'
	AND T0."Model" IN (54,39)
	AND T0."U_CodOrigemAMFS" IS NULL
	AND T0."DocEntry" = :list_of_cols_val_tab_del
	AND T0."CANCELED" = 'N'
)
 THEN
		      
	error := 7;
	error_message := 'O preço base não pode ser 0, favor veficiar o preço na tabela'; 
	END IF;

IF
	EXISTS(
	SELECT
		1
	FROM
		OINV NOTA
	INNER JOIN INV1 LINHA ON
		NOTA."DocEntry" = LINHA."DocEntry"
	WHERE
		NOTA."DocEntry" = :list_of_cols_val_tab_del
		AND NOTA."CANCELED" = 'N'
		AND LINHA."Usage" IN(129,130)
		AND LINHA."U_LBR_Destinacao" <> 'DESPESA'
)
THEN 
 error := 7;

error_message := 'Não e permitido utilizar essa utilização com destinação diferente de DESPESA!';
END IF;

IF EXISTS (
    SELECT 
        1
    FROM 
        (
            SELECT
                "DocEntry",
                SUM("LineTotal") AS frete
            FROM 
                INV13
            GROUP BY 
                "DocEntry"
        ) AS FRETE
    INNER JOIN 
        (
            SELECT
                "DocEntry",
                "TotalExpns"
            FROM
                OINV
            WHERE
                "CANCELED" = 'N'
                AND "DocEntry" = :list_of_cols_val_tab_del
        ) AS NOTA
    ON 
        FRETE."DocEntry" = NOTA."DocEntry"
    WHERE 
        FRETE.frete <> NOTA."TotalExpns"
)
THEN
    error := 7;
    error_message := 'Diferença entre frete e total de despesas encontrada.';
END IF;

IF EXISTS (
  SELECT 1
  FROM "OINV" o
  JOIN OCTG c
    ON c."GroupNum" = o."GroupNum"
   AND c."U_Rov_EnviarForca" = '2'    
  WHERE o."DocEntry" = :list_of_cols_val_tab_del
    AND o."CANCELED"  = 'N'
) THEN
  error         := 7;
  error_message := 'Essa condição de pagamento não está liberada.';
END IF;
 IF EXISTS(
	SELECT 
    1
	FROM 
	OINV N
	INNER JOIN INV1 L ON N."DocEntry" = L."DocEntry" 
	INNER JOIN OITW D ON D."ItemCode" = L."ItemCode" AND D."WhsCode" = L."WhsCode" 
	WHERE L."Usage" IN (5,110,130,129,11)
	AND ROUND(L."INMPrice",2) <>  ROUND(D."AvgPrice",2) 
	AND N.CANCELED = 'N'
	AND N."DocEntry" = :list_of_cols_val_tab_del
	LIMIT 1
)
THEN
SELECT 
	L."ItemCode",
	ROUND(L."INMPrice",2),
	ROUND(D."AvgPrice",2) 
	INTO itemCode,precoNota,precoEstoque
	FROM 
	OINV N
	INNER JOIN INV1 L ON N."DocEntry" = L."DocEntry" 
	INNER JOIN OITW D ON D."ItemCode" = L."ItemCode" AND D."WhsCode" = L."WhsCode" 
	WHERE L."Usage" IN (5,110,130,129,11)
	AND ROUND(L."INMPrice",2) <> ROUND(D."AvgPrice",2) 
	AND N.CANCELED = 'N'
	AND N."DocEntry" = :list_of_cols_val_tab_del
	LIMIT 1;
	
			error := 7;
	    	error_message := 'Preço unitario diferente do estoque ' || 'Item: ' || itemcode || 'preco nota ' || precoNota || ' preco estoque ' || precoEstoque; 
 END IF;

END IF;
-----------------------------------------------------------------------------------------------------------


/*
 * Cadastro de cliente integro
 */

IF :object_type in('2') and  (:transaction_type = 'A' or :transaction_type = 'U')  then 
/*
	IF EXISTS (SELECT '1' FROM ValidacaoParceiroNegocioPrazoSutenutri WHERE "CardCode" = :list_of_cols_val_tab_del) THEN
		SELECT TOP 1
			MSG into error_message
		FROM
			ValidacaoParceiroNegocioPrazoSutenutri
		WHERE "CardCode" = :list_of_cols_val_tab_del;
		error := 334;	
	END if;
*/


	IF EXISTS (SELECT '1' FROM ValidacaoParceiroNegocioSutenutri WHERE "CardCode" = :list_of_cols_val_tab_del) THEN
		SELECT TOP 1
			MSG into error_message
		FROM
			ValidacaoParceiroNegocioSutenutri
		WHERE "CardCode" = :list_of_cols_val_tab_del;
		error := 335;	
	END if;


 IF EXISTS(
SELECT
	pn."CardCode",
	pn."CreditLine",
	MAX(l."LogInstanc")
FROM
	OCRD pn
	LEFT JOIN ACRD l on(l."CardCode" = pn."CardCode")
WHERE
	pn."CardCode" = :list_of_cols_val_tab_del
	AND  pn."UserSign2" NOT in(171,84,83,32)
GROUP BY
	pn."CardCode",
	pn."CreditLine"
HAVING
	0 <> COALESCE(pn."CreditLine",0)-COALESCE((SELECT sl."CreditLine" FROM ACRD sl WHERE sl."CardCode" = pn."CardCode" AND sl."LogInstanc" = MAX(l."LogInstanc")),0)
 )
 THEN
			error := 7;
	    	error_message := 'VOCE NÃO TEM PERMISSÃO PARA ALTERAR O LIMITE DE CREDITO'; 
	END IF;

end if;


-------------------------------LANC CONTABIL BANCO DIF. FILIAL----------------------------
IF :object_type = '30'
AND (:transaction_type = 'A'
OR :transaction_type = 'U') THEN
IF EXISTS(
SELECT
	1
FROM
	OJDT JLC
LEFT JOIN JDT1 LCM ON
	JLC."TransId" = LCM."TransId"
LEFT JOIN OACT CT ON
	LCM."Account" = CT."AcctCode"
WHERE
	LCM."Account" = '1.1.1.002.00004'
	AND LCM."BPLId" <> 16
	AND LCM."TransId" = :list_of_cols_val_tab_del
)
THEN
	error := 3;

error_message := 'A FILIAL SELECIONADA DO BANCO ESTÁ DIFERENTE DA VINCULADA AO BANCO';
END IF;
END IF;
-------------------------TRAVA BAIXA FINANCEIRA SOMENTE NF AUTORIZADA CR ----------------
IF :object_type = '24'
AND (:transaction_type = 'A'
	OR :transaction_type = 'U') THEN
IF EXISTS (
SELECT
	1
FROM
	ORCT T0
LEFT JOIN RCT2 T1 ON
	T1."DocNum" = T0."DocEntry"
LEFT JOIN OINV T2 ON
	T2."DocEntry" = T1."DocEntry"
INNER JOIN "Process" NF ON
	T2."DocEntry" = NF."DocEntry"
	AND T2."ObjType" = NF."DocType"
LEFT JOIN INV1 LNS ON
	T2."DocEntry" = LNS."DocEntry"
LEFT JOIN OUSG UT ON
	LNS."Usage" = UT.ID
WHERE
	LNS."FreeChrgBP" = 'N'
	AND T2."Model" IN (39, 54)
		AND NF."StatusId" <> 4
		AND T0."DocEntry" = :list_of_cols_val_tab_del
		AND T1."InvType" = 13
)
THEN 
	error := 3;

error_message := 'A NOTA FISCAL NÃO ESTÁ AUTORIZADA!';
END IF;
END IF;
------------------------TRAVA BAIXA FINANCEIRA SOMENTE NF AUTORIZADA CP -----------------
IF :object_type = '46'
AND (:transaction_type = 'A'
	OR :transaction_type = 'U') THEN
IF EXISTS (
SELECT
	1
FROM
	OVPM T0
LEFT JOIN VPM2 T1 ON
	T1."DocNum" = T0."DocEntry"
LEFT JOIN OPCH T2 ON
	T2."DocEntry" = T1."DocEntry"
INNER JOIN "Process" NF ON
	T2."DocEntry" = NF."DocEntry"
	AND T2."ObjType" = NF."DocType"
LEFT JOIN PCH1 LNE ON
	T2."DocEntry" = LNE."DocEntry"
LEFT JOIN OUSG UT ON
	LNE."Usage" = UT.ID
WHERE
	LNE."FreeChrgBP" = 'N'
	AND T2."Model" IN (39, 54)
		AND NF."StatusId" <> 4
		AND T0."DocEntry" = :list_of_cols_val_tab_del
		AND T1."InvType" = 13
)
THEN 
	error := 3;

error_message := 'A NOTA FISCAL NÃO ESTÁ AUTORIZADA!';
END IF;
END IF;
----------------------------------------------------------------------------------------
----------------------NOTA DE SAÍDA E NF DE ENTREGA FUTURA------------------------------
IF :object_type = '13'
AND (:transaction_type = 'C'
	OR :transaction_type = 'A') THEN
IF EXISTS 
(
SELECT
	1
FROM
	INV1 LNS
INNER JOIN OINV NS ON
	NS."DocNum" = LNS."BaseRef"
	AND NS."DocEntry" = LNS."BaseEntry"
LEFT JOIN "Process" ST ON
	NS."ObjType" = ST."DocType"
	AND NS."DocEntry" = ST."DocEntry"
WHERE
	ST."StatusId" NOT IN (28, 25, 24, 17, 10)
		AND LNS."DocEntry" = :list_of_cols_val_tab_del
		AND (LNS."BaseRef" IS NULL
			OR LNS."BaseRef" <> ''))
THEN 
	error := 3;

error_message := 'CANCELAMENTO NÃO PERMITIDO, NF-E AINDA ESTÁ AUTORIZADA!';
END IF;
END IF;
-------------------------------DEV. NOTA FISCAL SAIDA-------------------------------------
IF :object_type = '14'
AND (:transaction_type = 'C'
	OR :transaction_type = 'A') THEN
IF EXISTS 
(
SELECT
	1
FROM
	RIN1 DNS
INNER JOIN ORIN DV ON
	DV."DocNum" = DNS."BaseRef"
	AND DV."DocEntry" = DNS."BaseEntry"
LEFT JOIN "Process" ST ON
	DV."ObjType" = ST."DocType"
	AND DV."DocEntry" = ST."DocEntry"
WHERE
	ST."StatusId" NOT IN (28, 25, 24, 17, 10)
		AND DNS."DocEntry" = :list_of_cols_val_tab_del
		AND (DNS."BaseRef" IS NULL
			OR DNS."BaseRef" <> ''))
THEN 
	error := 3;

error_message := 'CANCELAMENTO NÃO PERMITIDO, NF-E AINDA ESTÁ AUTORIZADA!';
END IF;
END IF;
-------------------------------------ENTREGA--------------------------------------------
IF :object_type = '15'
AND (:transaction_type = 'C'
	OR :transaction_type = 'A') THEN
IF EXISTS 
(
SELECT
	1
FROM
	DLN1 LEN
INNER JOIN ODLN EN ON
	EN."DocNum" = LEN."BaseRef"
	AND EN."DocEntry" = LEN."BaseEntry"
LEFT JOIN "Process" ST ON
	EN."ObjType" = ST."DocType"
	AND EN."DocEntry" = ST."DocEntry"
WHERE
	ST."StatusId" NOT IN (28, 25, 24, 17, 10)
		AND LEN."DocEntry" = :list_of_cols_val_tab_del
		AND (LEN."BaseRef" IS NULL
			OR LEN."BaseRef" <> ''))
THEN 
	error := 3;

error_message := 'CANCELAMENTO NÃO PERMITIDO, NF-E AINDA ESTÁ AUTORIZADA!';
END IF;
IF EXISTS (
  SELECT
    1
  FROM
    ODLN NOTA
    left JOIN DLN1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
  WHERE
    LINHA."Usage" = 17
    AND NOTA."Model" = 39
    AND NOTA."CANCELED" = 'N'
    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
    AND LINHA."CFOPCode" IN ('5922', '6922')
) THEN error:= 7;
error_message:= 'CFOP Errado!';
END IF;
END IF;
-----------------------------------------------------------------------------------------
----------------------NOTA DE ENTRADA  E NF RECEBIMENTO FUTURO---------------------------
IF :object_type = '18'
AND (:transaction_type = 'C'
	OR :transaction_type = 'A') THEN
IF EXISTS 
(
SELECT
	1
FROM
	PCH1 LNE
INNER JOIN OPCH NE ON
	NE."DocNum" = LNE."BaseRef"
	AND NE."DocEntry" = LNE."BaseEntry"
LEFT JOIN "Process" ST ON
	NE."ObjType" = ST."DocType"
	AND NE."DocEntry" = ST."DocEntry"
WHERE
	ST."StatusId" NOT IN (28, 25, 24, 17, 10)
		AND LNE."DocEntry" = :list_of_cols_val_tab_del
		AND (LNE."BaseRef" IS NULL
			OR LNE."BaseRef" <> ''))
THEN 
	error := 3;

error_message := 'CANCELAMENTO NÃO PERMITIDO, NF-E AINDA ESTÁ AUTORIZADA!';
END IF;
END IF;
----------------------RECEBIMENTO DE MERCADORIA------------------------------------------ 
IF :object_type = '20'
AND (:transaction_type = 'C'
	OR :transaction_type = 'A') THEN
IF EXISTS 
(
SELECT
	1
FROM
	PDN1 LRM
INNER JOIN OPDN RM ON
	RM."DocNum" = LRM."BaseRef"
	AND RM."DocEntry" = LRM."BaseEntry"
LEFT JOIN "Process" ST ON
	RM."ObjType" = ST."DocType"
	AND RM."DocEntry" = ST."DocEntry"
WHERE
	ST."StatusId" NOT IN (28, 25, 24, 17, 10)
		AND LRM."DocEntry" = :list_of_cols_val_tab_del
		AND (LRM."BaseRef" IS NULL
			OR LRM."BaseRef" <> ''))
THEN 
	error := 3;

error_message := 'CANCELAMENTO NÃO PERMITIDO, NF-E AINDA ESTÁ AUTORIZADA!';
END IF;
END IF;
----------------------DEVOLUÇÃO DE MERCADORIA---------------------------------------------- 
IF :object_type = '21'
AND (:transaction_type = 'C'
	OR :transaction_type = 'A') THEN
IF EXISTS 
(
SELECT
	1
FROM
	RPD1 LDM
INNER JOIN ORPD DM ON
	DM."DocNum" = LDM."BaseRef"
	AND DM."DocEntry" = LDM."BaseEntry"
LEFT JOIN "Process" ST ON
	DM."ObjType" = ST."DocType"
	AND DM."DocEntry" = ST."DocEntry"
WHERE
	ST."StatusId" NOT IN (28, 25, 24, 17, 10)
		AND LDM."DocEntry" = :list_of_cols_val_tab_del
		AND (LDM."BaseRef" IS NULL
			OR LDM."BaseRef" <> ''))
THEN 
	error := 3;

error_message := 'CANCELAMENTO NÃO PERMITIDO, NF-E AINDA ESTÁ AUTORIZADA!';
END IF;
END IF;
----------------------DEV. NOTA FISCAL ENTRADA--------------------------------------------- 
IF :object_type = '19'
AND (:transaction_type = 'C'
	OR :transaction_type = 'A') THEN
IF EXISTS 
(
SELECT
	1
FROM
	RPC1 LDE
INNER JOIN ORPC DNE ON
	DNE."DocNum" = LDE."BaseRef"
	AND DNE."DocEntry" = LDE."BaseEntry"
LEFT JOIN "Process" ST ON
	DNE."ObjType" = ST."DocType"
	AND DNE."DocEntry" = ST."DocEntry"
WHERE
	ST."StatusId" NOT IN (28, 25, 24, 17, 10)
		AND LDE."DocEntry" = :list_of_cols_val_tab_del
		AND (LDE."BaseRef" IS NULL
			OR LDE."BaseRef" <> ''))
THEN 
	error := 3;

error_message := 'CANCELAMENTO NÃO PERMITIDO, NF-E AINDA ESTÁ AUTORIZADA!';
END IF;
END IF;
------------------ TRAVA NOTA DE ENTRADA - CAMPO "Sujeito IRF"  ------------------------
IF :object_type = '18'
AND (:transaction_type = 'A'
    OR :transaction_type = 'U') THEN
IF EXISTS (
SELECT
    1
FROM
    PCH1
INNER JOIN CRD11 ON CRD11."CardCode" = PCH1."BaseCard"
INNER JOIN OPCH ON OPCH."DocEntry" = PCH1."DocEntry" 
WHERE
    PCH1."DocEntry" = :list_of_cols_val_tab_del
    AND CRD11."TributType" = 11
    AND PCH1."WtLiable" <> 'Y'
    AND OPCH."Model" = 54
    ) THEN
        error := 3;
        error_message := 'O parceiro é um Produtor Rural, portanto é necessário que o campo "Sujeito IRF" esteja marcado como SIM';
END IF;
END IF;
------------------TRAVA PEDIDO - NOTA SAÍDA - QUANTIDADE PENDENTES ------------------------
IF :object_type = '13'
AND (:transaction_type = 'A')THEN
IF EXISTS 
(
SELECT
	1
FROM
	OINV
INNER JOIN INV1 ON
	OINV."DocEntry" = INV1."DocEntry"
INNER JOIN RDR1 ON
	RDR1."DocEntry" = INV1."BaseEntry"
	AND RDR1."LineNum" = INV1."BaseLine"
INNER JOIN ORDR ON
	ORDR."DocEntry" = RDR1."DocEntry"
WHERE
	OINV."DocType" <> 'S'
	AND ORDR."DocEntry" = :list_of_cols_val_tab_del
	AND INV1."Quantity" > RDR1."Quantity"
	AND RDR1."OpenCreQty" >= 0
) THEN 
        error := 3;

error_message := 'A QUANTIDADE DOS ITENS ESTÁ MAIOR QUE A DO PEDIDO!';
END IF;
IF EXISTS (
  SELECT
    1
  FROM
    OINV NOTA
    left JOIN INV1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
  WHERE
    LINHA."Usage" = 16
    AND NOTA."Model" = 39
    AND NOTA."CANCELED" = 'N'
    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
    AND LINHA."CSTfPIS" <> 99
) THEN error:= 7;
error_message:= 'CST errado!';
END IF;
IF EXISTS (
	SELECT 1 FROM OINV o 
	INNER JOIN inv1 l ON o."DocEntry" = l."DocEntry" 
	LEFT JOIN OUSG U ON L."Usage" = U.ID
	WHERE o."DocEntry" = :list_of_cols_val_tab_del
	AND o.CANCELED = 'N'
	AND U."U_SEMPedido" = 'NAO'
	AND l."BaseEntry" IS NULL
)
  THEN
  error:= 7;
  error_message := 'Essa utilização não permite criar nota sem pedido de venda';
  END IF;
END IF;
------------------TRAVA PEDIDO DE COMPRA - CAMPO CONTA DO RAZAO ------------------------
IF :object_type = '22'
AND (:transaction_type = 'A'
	OR :transaction_type = 'U') THEN
IF EXISTS(
SELECT
	1
FROM
	OPOR
INNER JOIN POR1 ON
	OPOR."DocEntry" = POR1."DocEntry"
WHERE
	OPOR."DocEntry" = :list_of_cols_val_tab_del
	AND (POR1."AcctCode" IS NULL
		OR TRIM(POR1."AcctCode") = '')
)
THEN 
        error := 3;

error_message := 'Campo do Conta do Razão sem preenchimento! Procurar Contabilidade.';
END IF;
END IF;
------------------ TRAVA PEDIDO DE VENDA - CAMPO CONTA DO RAZAO ------------------------
IF :object_type = '17'
AND (:transaction_type = 'A'
	OR :transaction_type = 'U') THEN
IF EXISTS(
SELECT
	1
FROM
	ORDR
INNER JOIN RDR1 ON
	ORDR."DocEntry" = RDR1."DocEntry"
WHERE
	ORDR."DocEntry" = :list_of_cols_val_tab_del
	AND (RDR1."AcctCode" IS NULL
		OR TRIM(RDR1."AcctCode") = '')
)
THEN 
        error := 3;

error_message := 'Campo do Conta do Razão sem preenchimento! Procurar Contabilidade.';
END IF;
IF EXISTS (
    SELECT 
        1
    FROM 
        (
            SELECT
                "DocEntry",
                SUM("LineTotal") AS frete
            FROM 
                RDR13
            GROUP BY 
                "DocEntry"
        ) AS FRETE
    INNER JOIN 
        (
            SELECT
                "DocEntry",
                "TotalExpns"
            FROM
                ORDR
            WHERE
                "CANCELED" = 'N'
                AND "DocEntry" = :list_of_cols_val_tab_del
        ) AS NOTA
    ON 
        FRETE."DocEntry" = NOTA."DocEntry"
    WHERE 
        FRETE.frete <> NOTA."TotalExpns"
)
THEN
    error := 7;
    error_message := 'Diferença entre frete e total de despesas encontrada.';
END IF;
END IF;
------------- TRAVA NOTA DE ENTRADA - CAMPO DATA DE VENCIMENTO E PRESTAÇÕES -------------
IF :object_type = '18' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN
	IF EXISTS (
    SELECT 1
    FROM "PCH6" T0
    INNER JOIN "OPCH" T1 ON T0."DocEntry" = T1."DocEntry"
    WHERE (
        T0."DueDate" < T1."DocDate" OR 
        T1."DocDueDate" < T1."DocDate"
    )
    AND T0."PaidToDate" = 0
    AND T0."DocEntry" = :list_of_cols_val_tab_del
    ) THEN
        error := 3;
        error_message := 'Verifique campo de Data de Vencimento ou Prestações, não é permitido datas retroativas!';
    END IF;



IF EXISTS (
  SELECT
    1
  FROM
    OPCH NOTA
    left JOIN PCH1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
    LEFT JOIN pch12 ON NOTA."DocEntry" = PCH12."DocEntry"
  WHERE
    PCH12."Incoterms" = 1
    AND LINHA."Usage" = 15
    AND NOTA."Model" = 39
    AND NOTA."U_TX_TagCTe" IS NULL
    AND NOTA."CANCELED" = 'N'
    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
    AND NOT LINHA."ItemCode" = 'INS0000221' 
) THEN error:= 7;
error_message:= 'Nota sem CTE! Favor informe o CTE.';
END IF;
IF EXISTS (
SELECT
   1
FROM
    OPCH NOTA
    LEFT JOIN PCH1 LINHA ON NOTA."DocEntry" = LINHA."DocEntry"
    LEFT JOIN PCH12 ON NOTA."DocEntry" = PCH12."DocEntry"
WHERE
    PCH12."Incoterms" = 1
    AND LINHA."Usage" = 15
    AND NOTA."Model" = 39
    AND NOTA."CANCELED" = 'N'
    AND NOTA."DocEntry" = :list_of_cols_val_tab_del
    AND LINHA."ItemCode" <> 'INS0000221'
    AND NOT EXISTS (
        SELECT
            1
        FROM
            OPCH NOTA1
        WHERE
            (
                (NOTA1."U_ChaveAcesso" = NOTA."U_TX_TagCTe" AND NOTA1."Model" = 45)
                OR (TO_NVARCHAR(NOTA1."DocEntry") = TO_NVARCHAR(NOTA."U_TX_TagCTe") 
                AND NOTA1."Model" = 46)

            )
)
) THEN error:= 7;
error_message:= 'Infome um CTE Valido!.';
END IF;



IF EXISTS(
WITH
CUSTO_NOTA AS (
    SELECT
        OPCH."DocEntry",
        OPCH."DocNum",
        OPCH."DocDate",
        OPCH."BPLId",
        OPCH."Serial",
        PCH1."ItemCode",
        PCH1."InvQty",
        (PCH1."Quantity" * PCH1."Price") - SUM(PCH4."TaxSum") AS VALOR_TRANSACAO,
        ((PCH1."Quantity" * PCH1."Price") - SUM(PCH4."TaxSum")) / NULLIF(PCH1."InvQty", 0) AS CUSTO_QUE_ENTRA,
        PCH1."WhsCode"
    FROM
        PCH1
    INNER JOIN OPCH ON OPCH."DocEntry" = PCH1."DocEntry"
    INNER JOIN PCH4 ON PCH1."DocEntry" = PCH4."DocEntry"
        AND PCH1."LineNum" = PCH4."LineNum"
    WHERE
        PCH1."DocEntry" = :list_of_cols_val_tab_del
        AND OPCH."CANCELED" = 'N'
        AND PCH1."Usage" = 15
        AND OPCH."Model" = 39
        AND PCH1."ItemCode" NOT IN ('INS0000136')
    GROUP BY
        OPCH."DocEntry",
        PCH1."ItemCode",
        PCH1."InvQty",
        PCH1."Quantity",
        PCH1."Price",
        PCH1."WhsCode",
        OPCH."DocNum",
        OPCH."BPLId",
        OPCH."Serial",
        OPCH."DocDate"
),

TRANSACOES AS (
    SELECT
        ESTOQUE."TransValue",
        ESTOQUE."InQty" - ESTOQUE."OutQty" AS "InQty",
        ESTOQUE."ItemCode",
        ESTOQUE."Warehouse",
        ROW_NUMBER() OVER (PARTITION BY ESTOQUE."ItemCode"
            ORDER BY ESTOQUE."TransNum" DESC) AS RowNum
    FROM
        OINM ESTOQUE
    INNER JOIN CUSTO_NOTA ON ESTOQUE."ItemCode" = CUSTO_NOTA."ItemCode"
        AND ESTOQUE."Warehouse" = CUSTO_NOTA."WhsCode"
),

CUSTO_MEDIO AS (
    SELECT 
        "ItemCode",
        "Warehouse",
        SUM("TransValue") AS VALOR,
        SUM("InQty") AS QUANTIDADE
    FROM TRANSACOES
    WHERE RowNum >= 2
    GROUP BY "ItemCode", "Warehouse"
),

VARIACAO_CUSTO AS (
    SELECT
        NOTA."DocEntry",
        NOTA."DocDate",
        NOTA."DocNum",
        NOTA."BPLId",
        NOTA."Serial",
        NOTA."ItemCode",
        NOTA."WhsCode",
        CASE
            WHEN ESTOQUE.QUANTIDADE <> 0 
            THEN ESTOQUE.VALOR / ESTOQUE.QUANTIDADE
            ELSE 0
        END AS CUSTO_MEDIO,
        CASE
            WHEN ESTOQUE.QUANTIDADE <> 0 AND ESTOQUE.VALOR <> 0 
            THEN ((NOTA.CUSTO_QUE_ENTRA - (ESTOQUE.VALOR / ESTOQUE.QUANTIDADE)) / (ESTOQUE.VALOR / ESTOQUE.QUANTIDADE)) * 100
            ELSE 0
        END AS VARIACAO,
        NOTA.CUSTO_QUE_ENTRA
    FROM
        CUSTO_MEDIO ESTOQUE
    INNER JOIN CUSTO_NOTA NOTA 
        ON NOTA."ItemCode" = ESTOQUE."ItemCode"
        AND NOTA."WhsCode" = ESTOQUE."Warehouse"
    WHERE
        NOTA."ItemCode" LIKE 'INS%'
        AND NOTA."BPLId" = 2
        AND NOTA."DocDate" >= '20240101'
)

SELECT *
FROM VARIACAO_CUSTO
WHERE VARIACAO > 50 OR VARIACAO < -50

) THEN
        error := 7;

error_message := 'Desvio de custo muito alto!';
END IF;
END IF;

IF :object_type = '60' AND :transaction_type = 'A' THEN

    IF EXISTS (
        WITH SAIDA_INSUMO AS (
            SELECT L."ItemCode", L."WhsCode"
              FROM OIGE N
              JOIN IGE1 L ON N."DocEntry" = L."DocEntry"
             WHERE L."DocEntry" = :list_of_cols_val_tab_del
        ),
        ESTOQUE AS (
            SELECT MAX(E."CreatedBy") AS "DocEntry", E."ItemCode"
              FROM OINM E
              JOIN SAIDA_INSUMO S 
                ON E."ItemCode"  = S."ItemCode"
               AND E."Warehouse" = S."WhsCode"
             WHERE E."TransType" = '18'
               AND E."DocDate"   > '2025-07-14'
             GROUP BY E."ItemCode"
        ),
        NOTA AS (
            SELECT N."DocEntry", N."DocNum", L."ItemCode"
              FROM OPCH N
              JOIN PCH1 L       ON N."DocEntry" = L."DocEntry"
              JOIN ESTOQUE E    ON N."DocEntry" = E."DocEntry"
              LEFT JOIN PCH12 P ON N."DocEntry" = P."DocEntry"
             WHERE N."CANCELED"   = 'N'
               AND L."Usage"      = '15'
               AND P."Incoterms"  = 1
               AND N."Model"      = 39
               AND L."ItemCode" <> 'INS0000221'
               AND NOT EXISTS (
                   SELECT 1 
                     FROM IPF1 DI
                    WHERE DI."BaseEntry" = N."DocEntry"
                      AND DI."ItemCode" = L."ItemCode"
               )
        )
        SELECT 1 FROM NOTA
    ) THEN

        SELECT "DocNum"
          INTO notaSemDespesa
          FROM (
            WITH SAIDA_INSUMO AS (
                SELECT L."ItemCode", L."WhsCode"
                  FROM OIGE N
                  JOIN IGE1 L ON N."DocEntry" = L."DocEntry"
                 WHERE L."DocEntry" = :list_of_cols_val_tab_del
            ),
            ESTOQUE AS (
                SELECT MAX(E."CreatedBy") AS "DocEntry", E."ItemCode"
                  FROM OINM E
                  JOIN SAIDA_INSUMO S 
                    ON E."ItemCode"  = S."ItemCode"
                   AND E."Warehouse" = S."WhsCode"
                 WHERE E."TransType" = '18'
                   AND E."DocDate"   > '2025-07-14'
                 GROUP BY E."ItemCode"
            ),
            NOTA AS (
                SELECT N."DocEntry", N."DocNum", L."ItemCode"
                  FROM OPCH N
                  JOIN PCH1 L       ON N."DocEntry" = L."DocEntry"
                  JOIN ESTOQUE E    ON N."DocEntry" = E."DocEntry"
                  LEFT JOIN PCH12 P ON N."DocEntry" = P."DocEntry"
                 WHERE N."CANCELED"   = 'N'
                   AND L."Usage"      = '15'
                   AND P."Incoterms"  = 1
                   AND N."Model"      = 39
                   AND L."ItemCode" <> 'INS0000221'
                       AND NOT EXISTS (
                   SELECT 1 
                     FROM IPF1 DI
                    WHERE DI."BaseEntry" = N."DocEntry"
                      AND DI."ItemCode" = L."ItemCode"
               )
            )
            SELECT "DocNum"
              FROM NOTA
             ORDER BY "DocNum"
             LIMIT 1
        );
        error := 7;
        error_message := 'Não foi feito despesa de importação da nota: ' || notaSemDespesa;

    END IF;
END IF;


IF :object_type = '59' AND :transaction_type = 'A' THEN
	IF EXISTS(
		SELECT 1 FROM IGN1 i 
		WHERE 
		i."DocEntry" =  :list_of_cols_val_tab_del
		AND i."WhsCode" = '500.30'
		AND NOT EXISTS(SELECT 1 FROM IGN21 WHERE "DocEntry" = :list_of_cols_val_tab_del)
		)
		THEN
		 error := 7;
         error_message := 'Favor colocar referencia da nota de remessa demonstração';

END IF;
END IF;


----------------------------------------------------------------------------------------------
---------------------------Despesa de importaçao----------------------------------------------------------------
if  :object_type = '69' and (:transaction_type = 'A') THEN
IF EXISTS (
	SELECT 
	  O."DocNum"   AS "OrdemOIPF",
	  NF."DocNum"  AS "NotaEntrada",
	  CTE."DocNum" AS "CTeDocNum",
	  O."DocDate"  AS "DataOIPF",
	  NF."DocDate" AS "DataEntrada",
	  CTE."DocDate"AS "DataCTe"
	FROM OIPF O
	INNER JOIN IPF1 I 
	  ON O."DocEntry" = I."DocEntry"
	LEFT JOIN PCH1 PL 
	  ON I."BaseEntry" = PL."DocEntry"
	 AND I."ItemCode"  = PL."ItemCode"
	LEFT JOIN OPCH NF 
	  ON PL."DocEntry"  = NF."DocEntry"
	 AND NF."CANCELED"  = 'N'
	LEFT JOIN OPCH CTE 
	  ON (
			(CTE."U_ChaveAcesso" = NF."U_TX_TagCTe" AND CTE."Model" = 45)
			OR 
			(TO_NVARCHAR(CTE."DocEntry") = NF."U_TX_TagCTe" AND CTE."Model" = 46)
		 )
	 AND CTE."CANCELED" = 'N'
	WHERE 
	   O."DocEntry"  = :list_of_cols_val_tab_del
	  AND O."DocDate" <> CTE."DocDate"
)
THEN 
    error := 7;
	error_message := 'A data está diferente do CTE!';
END IF;


SELECT 
  CTELINHA."LineTotal"
  - IFNULL((
      SELECT SUM("TaxSumSys")
        FROM PCH4
       WHERE "DocEntry" = CTE."DocEntry"
    ), 0),
     CTELINHA."LineTotal"
  - IFNULL((
      SELECT SUM("TaxSumSys")
        FROM PCH4
       WHERE "DocEntry" = CTE."DocEntry"
    ), 0)
  - O."CostSum"
INTO v_frete_sem_imp, v_diff
FROM OIPF O
JOIN IPF1 I      
  ON O."DocEntry" = I."DocEntry"
LEFT JOIN PCH1 PL 
  ON I."BaseEntry" = PL."DocEntry"
 AND I."ItemCode"  = PL."ItemCode"
LEFT JOIN OPCH NF 
  ON PL."DocEntry"  = NF."DocEntry"
 AND NF."CANCELED"  = 'N'
LEFT JOIN OPCH CTE
  ON (
        (CTE."U_ChaveAcesso" = NF."U_TX_TagCTe" AND CTE."Model" = 45)
     OR (TO_NVARCHAR(CTE."DocEntry") = NF."U_TX_TagCTe" AND CTE."Model" = 46)
     )
 AND CTE."CANCELED" = 'N'
LEFT JOIN PCH1 CTELINHA
  ON CTELINHA."DocEntry" = CTE."DocEntry"
WHERE O."DocEntry" = :list_of_cols_val_tab_del
LIMIT 1;

IF v_diff <> 0 THEN
  error         := 7;
  error_message := 'O valor do frete está errado! Valor correto: ' || v_frete_sem_imp;
END IF;
END IF;


----------------------------------------------------------------------------------------------

IF :object_type = '18' and (:transaction_type = 'A') THEN
	IF  EXISTS (
	SELECT 1
    FROM OPCH
    INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"
    WHERE 
    	OPCH."DocEntry" = :list_of_cols_val_tab_del
	    AND OPCH."CANCELED" = 'N'
	    AND PCH1."Usage" in(57,73)
    	AND 
		    NOT EXISTS (
		    SELECT 1 FROM 
		    PCH21 WHERE PCH21."DocEntry" = :list_of_cols_val_tab_del
		    )
    )
    
	THEN
		error := 7;
    	error_message := 'Colocar referencia da nota';  
	END if;
	
		IF  EXISTS (
	SELECT 1
    FROM OPCH
    INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"
    WHERE 
    	OPCH."DocEntry" = :list_of_cols_val_tab_del
	    AND OPCH."CANCELED" = 'N'
	    AND PCH1."Usage" IN (57)
	    AND PCH1."WhsCode" <> '500.11'
    )
    
	THEN
		error := 7;
    	error_message := 'Essa utilização deve ser usado o Depósito 500.11';  
	END if;
	
	IF EXISTS(
	SELECT 
		1
	FROM 
		OPCH N
	INNER JOIN PCH1 L 
		ON N."DocEntry" = L."DocEntry" 
	INNER JOIN OITW D 
		ON D."ItemCode" = L."ItemCode" 
		AND D."WhsCode" = '500.30'
	WHERE L."Usage" IN (73)
	  AND ROUND(L."INMPrice",2) <> ROUND(D."AvgPrice",2) 
	  AND N.CANCELED = 'N'
	  AND N."DocEntry" = :list_of_cols_val_tab_del
	LIMIT 1
)
THEN
	SELECT 
		L."ItemCode",
		ROUND(L."INMPrice",2),
		ROUND(D."AvgPrice",2) 
	INTO itemCode, precoNota, precoEstoque
	FROM 
		OPCH N
	INNER JOIN PCH1 L 
		ON N."DocEntry" = L."DocEntry" 
	INNER JOIN OITW D 
		ON D."ItemCode" = L."ItemCode" 
		AND D."WhsCode" = '500.30'
	WHERE L."Usage" IN (73)
	  AND ROUND(L."INMPrice",2) <> ROUND(D."AvgPrice",2) 
	  AND N.CANCELED = 'N'
	  AND N."DocEntry" = :list_of_cols_val_tab_del
	LIMIT 1;

	error := 7;
	error_message := 'Preço unitário diferente do estoque ' 
		|| 'Item: ' || itemCode 
		|| ' preco nota ' || precoNota 
		|| ' preco estoque ' || precoEstoque; 
END IF;
END if;
-----------------------------------------------------------------------------------------------
IF :object_type in('23') and  (:transaction_type = 'A' or :transaction_type = 'U') AND 1=2 THEN 
	SELECT 
		CASE :object_type
		WHEN '23' THEN 'QUT'
		END INTO pTblSuffix
	FROM dummy;
	pTblSuffix := 'QUT';

    query := 'select
				"CardCode"
			FROM "O'|| pTblSuffix || '"
			where "DocEntry" =' || :list_of_cols_val_tab_del;
		 
	EXECUTE IMMEDIATE query INTO cardCode;
	
	IF EXISTS (SELECT '1' FROM ValidacaoParceiroNegocioPrazoSutenutri WHERE "CardCode" = :cardCode) THEN
		SELECT TOP 1
			MSG into error_message
		FROM
			ValidacaoParceiroNegocioPrazoSutenutri
		WHERE "CardCode" = :cardCode;
		error := 334;	
	END if;
end if;
 

end;
