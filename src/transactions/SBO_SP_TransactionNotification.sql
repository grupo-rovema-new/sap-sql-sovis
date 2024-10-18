CREATE OR REPLACE PROCEDURE SBO_SP_TransactionNotification
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
error1 int;		
error2 int;
error3 int;
error4 int;
erroAdiantamento int;
XITEM nvarchar (255); 		-- Error string to be displayed
error_message nvarchar (255); 		-- Error string to be displayed
currDbNameForTaxOne nvarchar(128);
companyDbIntBank nvarchar(128);
begin

error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------
-------Nota Fiscal de Entrada---------------Suzi---03/03/2023

	---------------------------------FIM Nota Fiscal de Entrada-------------------------------------------------------------------------------------------------------------------


IF :object_type = '17' then
	IF( EXISTS(
		SELECT
			1
		FROM
			ORDR
		WHERE
			"UserSign2" != 162
			AND "DocEntry" = :list_of_cols_val_tab_del
			AND
			(
			"U_pedido_update" = '1'
			OR
			1 = (SELECT
					TOP 1 "U_pedido_update"
				FROM
					ADOC
				WHERE
					"ObjType" = 17
					AND "DocEntry" = :list_of_cols_val_tab_del
				GROUP BY "U_pedido_update"
				ORDER BY MAX("LogInstanc") DESC))
			)) THEN
		error := '666';
    	error_message := 'O item esta bloqueado para atualização de imposto desonerado';
	END if;
END IF;


--------------------------------------------------------------------------------------------------------------------------------

-------



------------------Trava para Nota Fiscal e Entrada- Fabio A.liberali - 20/09/2022 ----------------------------------
---------------	--Travas do Campo Observação do Diario -- 	----------------
if  (:object_type = '13' or :object_type = '18' or :object_type = '15' or :object_type = '14'  )
  and (:transaction_type = 'A'or :transaction_type = 'U') then
	Select 		 -- Nota fiscal de Entrada ---- 
 		count (1) into error
 	from OPCH T0
 	WHERE (T0."JrnlMemo" = '' or T0."JrnlMemo" is null ) AND	
 		T0."DocEntry" = :list_of_cols_val_tab_del;
	Select 		----  Nota Fiscal de Saida ---- 
 		count (1) into error1
 	From OINV T1
 	WHERE (T1."JrnlMemo" = '' or T1."JrnlMemo" is null ) AND
 		T1."DocEntry" = :list_of_cols_val_tab_del;
	Select		----  Entrega ---- 
		count (1) into error2	
	from ODLN T2
	WHERE (T2."JrnlMemo" = '' or T2."JrnlMemo" is null ) AND	
		T2."DocEntry" = :list_of_cols_val_tab_del;
	Select  	--- Dev Nota Fiscal de Saida ---- 
		count (1) into error3	
	From ORIN T3
	WHERE (T3."JrnlMemo" = '' or T3."JrnlMemo" is null ) AND	
		T3."DocEntry" = :list_of_cols_val_tab_del;
	IF (:error > 0) THEN       
		error := '1';
		error_message := 'Falta o campo Observação do Diário ';  
	END if;
	IF (:error1 > 0) THEN       
		error := '1';
		error_message := 'Falta o campo Observação do Diário ';  
	END if;
	IF (:error2 > 0) THEN       
		error := '1';
    	error_message := 'Falta o campo Observação do Diário ';  
	END if;
	IF (:error3 > 0) THEN       
		error := '1';
    	error_message := 'Falta o campo Observação do Diário ';  
	END if;
END if;

---------------------------------------NF de Entrada e Recebimento JÁ EXISTE----SUZI---06/03/2023------------------------------------------------------------------------------------------------------
if :object_type = '18' Or :object_type = '20'  and (:transaction_type = 'A')  then
 	if (:object_type = '18')  then
		
		Select 
			count(1) 
				into error
		From OPCH T0
		Where 
			T0."DocEntry" = :list_of_cols_val_tab_del and T0."CANCELED" = 'N' And 
			EXISTS(Select T10."DocEntry" From OPCH T10 
					Where T10."DocEntry" <> T0."DocEntry" And T10."Serial" = T0."Serial" 
					And T10."CardCode" = T0."CardCode"
					And T10."Model" = T0."Model"
				And T10."SeriesStr" = T0."SeriesStr"
					and T10."CANCELED" = 'N');
		 
		IF(:error > 0) THEN        
			error := 1;
         	error_message := 'Documento nota fiscal já existe';  
		End if;
	End IF; 
	

	if (:object_type = '20')  then
		
		Select 
			count(1) 
			into error
		From OPDN T0
		Where 
			T0."DocEntry" = :list_of_cols_val_tab_del and T0."CANCELED" = 'N' And 
			EXISTS(Select T10."DocEntry" From OPDN T10 
					Where T10."DocEntry" <> T0."DocEntry" And T10."Serial" = T0."Serial" 
					And T10."CardCode" = T0."CardCode"
					and T10."CANCELED" = 'N');
		 
		IF(:error > 0) THEN        
		error := 1;
         	error_message := 'Documento nota fiscal já existe';  
		End if;
	End IF;                
END IF;
IF :object_type = '18' and (:transaction_type = 'A') then 

	Select 
		count(1) 
		into error1
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
			T0."DocEntry" = :list_of_cols_val_tab_del;			

		IF(:error1 > 0) THEN        
			error := 1;
         	error_message := 'Informações da Série não confere com Chave de acesso.';  
	End if;	
		
	Select 
		count(1) 
		into error2
		From "OPCH" T0						
		Where 
			T0."Model" not in ('28','46','37','47')
			and
			Substring("U_ChaveAcesso",3,4) 
			not like 
			Substring(Concat(EXTRACT(year FROM Cast("TaxDate" as date)),RIGHT('0' || RTRIM(EXTRACT(month FROM Cast("TaxDate" as date))), 2)),3,6)
			and  T0."CANCELED" = 'N'
			and ifnull(T0."U_ChaveAcesso",'') <> ''
			and 
			T0."DocEntry" = :list_of_cols_val_tab_del;

		IF(:error2 > 0) THEN        
			error := 1;
         	error_message := 'Informações da data não confere com Chave de acesso.';  
         	
	End if;   			

	Select 
		count(1) 
		into error3
		From "OPCH" T0						
		Where 
			T0."Model" not in ('28','46','37','47')
			and
		   (Substring(T0."U_ChaveAcesso",26,9) not like '%'|| Cast(T0."Serial" as nvarchar)|| '%')
			and  T0."CANCELED" = 'N'
			and ifnull(T0."U_ChaveAcesso",'') <> ''
			and 
			T0."DocEntry" = :list_of_cols_val_tab_del;
			
       	IF(:error3 > 0) THEN        
			error := 1;
         	error_message := 'Informações da NF não confere com Chave de acesso.';  
	End if;
			
	Select 
		count(1) 
		into error4
		From "OPCH" T0	
		inner join "PCH12" T1 on T1."DocEntry" = T0."DocEntry"					
		Where 
		T0."Model" not in ('28','46','37','47')
		and T0."SeriesStr" not in ('890')
		and
		   		(T0."U_ChaveAcesso" not like  '%' || replace(replace(replace(IFNULL(T1."TaxId0",''),'/',''),'-',''),'.','') || '%'   or T1."TaxId0" is null or T1."TaxId0" = '')
			and ifnull(T0."U_ChaveAcesso",'') <> ''
			and (T1."TaxId4" is null or T1."TaxId4" = '')
			and  T0."CANCELED" = 'N'
			and 
			T0."DocEntry" = :list_of_cols_val_tab_del;
			
	IF(:error4 > 0) THEN        
			error := 1;
         	error_message := 'Informações do CNPJ não confere com Chave de acesso.';  
	End if;

		
end if;


SELECT CURRENT_SCHEMA INTO companyDbIntBank FROM DUMMY;


Call "IV_IB_TransNotificationValidateIntBank"(companyDbIntBank, companyDbIntBank, 'IV_IB_Setting', 'IV_IB_BillOfExchange', 'IV_IB_BillOfExchangeInstallment', 'IV_IB_CompanyLocal', object_type, transaction_type, list_of_cols_val_tab_del, error, error_message);
Call "IV_IB_TransacaoValidacaoPagamentoBankPlus"(companyDbIntBank, object_type, transaction_type, list_of_cols_val_tab_del, error, error_message);
Call "TransNotificationValidate"(companyDbIntBank, object_type, list_of_cols_val_tab_del, error, error_message);
Call SBO_SP_TRANSACTIONNOTIFICATION_Liberali(object_type,transaction_type,num_of_cols_in_key,list_of_key_cols_tab_del,list_of_cols_val_tab_del,error,error_message);
Call SBO_SP_TRANSACTIONNOTIFICATION_ROVEMA(object_type,transaction_type,num_of_cols_in_key,list_of_key_cols_tab_del,list_of_cols_val_tab_del,error,error_message);
Call SBO_SP_Validacao_Bloqueio_Periodo_Contabil(object_type,transaction_type,num_of_cols_in_key,list_of_key_cols_tab_del,list_of_cols_val_tab_del,error,error_message);
Call SBO_SP_VALIDACAO_POR_UTILIZACAO(object_type,transaction_type,num_of_cols_in_key,list_of_key_cols_tab_del,list_of_cols_val_tab_del,error,error_message);
Call SBO_SP_TransactionNotification_Katrid(object_type,transaction_type,num_of_cols_in_key,list_of_key_cols_tab_del,list_of_cols_val_tab_del,error,error_message);
/*Call SBO_SP_VALIDACAO_VENDA_FUTURA(object_type,transaction_type,num_of_cols_in_key,list_of_key_cols_tab_del,list_of_cols_val_tab_del,error,error_message);*/


-- LANÇAMENTO CONTABIL MANUAL
IF :object_type = '30' and (:transaction_type = 'A' OR :transaction_type = 'U') then 
	Select 
		count(1) 
		into error1
		From OJDT T0  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId"
		Where 
			T1."TransId"  = :list_of_cols_val_tab_del AND (T1."LineMemo" IS NULL OR LENGTH(TRIM(IFNULL(T1."LineMemo",''))) = 0);			

		IF(:error1 > 0) THEN        
			error := 1;
         	error_message := 'Não é permitido LCM sem histórico contábil.';  

		END IF;
END IF;

-- ENTRADA DE MERCADORIA
IF :object_type = '59' and (:transaction_type = 'A' OR :transaction_type = 'U') then 
	Select 
		count(1) 
		into error1
		From IGN1 T0 
		Where 
			T0."DocEntry"  = :list_of_cols_val_tab_del AND IFNULL("Price",0) = 0;			

		IF(:error1 > 0) THEN        
			error := 1;
         	error_message := 'Não é permitido a entrada de item sem preço.';  

		END IF;
END IF;

-- NOTA FISCAL DE SAÍDA
IF :object_type = '13' and (:transaction_type = 'A' OR :transaction_type = 'U') then 
    
    Select 
        count(1) 
        into error1
        From 
            INV1 T0 
            INNER JOIN OINV T1 ON T1."DocEntry" = T0."DocEntry"
        Where 
            T0."DocEntry"  = :list_of_cols_val_tab_del AND
            T0."BaseType" = '17' AND
            T1."CANCELED"  = 'N' AND
            "Get_Pedido_Venda_Permissao_Faturamento"(T0."BaseEntry", T0."BaseLine", T0."Quantity" ) <> 'Ok';

        IF(:error1 > 0) THEN
            SELECT 
                MIN("Get_Pedido_Venda_Permissao_Faturamento"(T0."BaseEntry", T0."BaseLine", T0."Quantity" )) 
                INTO
                XITEM
            From 
                INV1 T0 
                INNER JOIN OINV T1 ON T1."DocEntry" = T0."DocEntry"
            Where 
                T0."DocEntry"  = :list_of_cols_val_tab_del AND
                T0."BaseType" = '17' AND
                T1."CANCELED"  = 'N' AND
                "Get_Pedido_Venda_Permissao_Faturamento"(T0."BaseEntry", T0."BaseLine", T0."Quantity" ) <> 'Ok';
                   
                error := 1;
                 error_message := XITEM;  

        END IF;


--PAULO 09-09-2024.
    --VERIFICAÇÃO SE A NOTA É ENTREGA FUTURA. CASO POSITIVO, SO PERMITIR DESPESA ADICIONAL DE FRETE SIMPLES FATURAMENTO.
    -- SE NÃO, NÃO PERMITIR USO DA DESPESA DE SIMPLES FATURAMENTO.
    SELECT
        COUNT(A."DocEntry") 
        into XCOUNT
    FROM
        OINV A
    WHERE
        A."DocEntry" = :list_of_cols_val_tab_del AND A."CANCELED" = 'N' AND A."isIns" = 'Y';

    IF XCOUNT > 0 THEN
        SELECT COUNT(1) into error1 FROM INV3 T0 WHERE T0."DocEntry" = :list_of_cols_val_tab_del AND  T0."ExpnsCode" <> 5;
        
        IF error1 > 0 THEN
            error := 1;
               error_message := 'Despesa Adicional permitido somente Frete Simples Fatura para essa operação.';              
        END IF;
    
    END IF;
    IF XCOUNT = 0 THEN
        SELECT COUNT(1) into error1 FROM INV3 T0 WHERE T0."DocEntry" = :list_of_cols_val_tab_del AND  T0."ExpnsCode" = 5;
        
        IF error1 > 0 THEN
            error := 1;
               error_message := 'Frete Simples Fatura somente Nota Mãe.';              
        END IF;

    END IF;

    --PAULO 15-09-2024.
    --VERIFICAÇÃO SE A NOTA TEM DESPESA ADICIONAL. SE SIM, VERIFICAR SE TEM IMPOSTO PREENCHIDO
    SELECT
        COUNT(A."DocEntry") 
        into XCOUNT
    FROM
        INV3 A
    WHERE
        A."DocEntry" = :list_of_cols_val_tab_del;
    
    IF XCOUNT > 0 THEN
        SELECT COUNT(1) into error1 FROM INV13 T0 WHERE T0."DocEntry" = :list_of_cols_val_tab_del AND T0."TaxCode" IS NULL;
        
        IF error1 > 0 THEN
            error := 1;
               error_message := 'Despesa Adicional é necessario ter imposto.';              
        END IF;
    
    END IF;

END IF;
   
-- VENDAS -> ENTREGA
IF :object_type = '15' and (:transaction_type = 'A') then 

    --PAULO 09-09-2024.
    --VERIFICAÇÃO SE A ENTREGA É VINCULADA A UMA NOTA DE ENTREGA FUTURA E SE A DESPESA ADICIONAL NÃO É FRETE SIMPLES FATURAMENTO.
    SELECT
        COUNT(A."DocEntry") 
        into XCOUNT
    FROM
        ODLN A 
        LEFT JOIN DLN1 B ON A."DocEntry" = B."DocEntry"
    WHERE
        A."DocEntry" = :list_of_cols_val_tab_del AND A."CANCELED" = 'N' AND B."BaseType" = '13';

    IF XCOUNT > 0 THEN
        SELECT COUNT(1) into error1 FROM DLN3 T0 WHERE T0."DocEntry" = :list_of_cols_val_tab_del AND  T0."ExpnsCode" <> 5;
        
        IF error1 > 0 THEN
            error := 1;
               error_message := 'Despesa Adicional permitido somente Frete Simples Fatura nessa tela.';              
        END IF;
    END IF;        

    --PAULO 15-09-2024.
    --VERIFICAÇÃO SE A NOTA TEM DESPESA ADICIONAL. SE SIM, VERIFICAR SE TEM IMPOSTO PREENCHIDO
    SELECT
        COUNT(A."DocEntry") 
        into XCOUNT
    FROM
        INV3 A
    WHERE
        A."DocEntry" = :list_of_cols_val_tab_del;
    
    IF XCOUNT > 0 THEN
        SELECT COUNT(1) into error1 FROM DLN13 T0 WHERE T0."DocEntry" = :list_of_cols_val_tab_del AND LENGTH(T0."TaxCode") < 8;
        
        IF error1 > 0 THEN
            error := 1;
               error_message := 'Despesa Adicional é necessario ter imposto.';              
        END IF;
    
    END IF;

END IF;

select :error, SUBSTRING (:error_message,0,255) AS error_message FROM dummy;

end;
