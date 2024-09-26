CREATE OR REPLACE FUNCTION "Get_Pedido_Venda_Permissao_Faturamento"(DocEntrey integer, line_num integer, quantidade float ) RETURNS result NVARCHAR(200) LANGUAGE SQLSCRIPT AS


BEGIN

declare error  int;                -- Result (0 for no error)
declare error_message nvarchar (200);         -- Error string to be displayed
DECLARE Quantidade_Permitida float; 
DECLARE Quantidade_Faturada float; 
DECLARE Quantidade_Devolvida float; 
DECLARE Item nvarchar(255);
 
error_message := 'Ok';
    
SELECT 
    "OpenCreQty",
    "ItemCode"
    INTO
    Quantidade_Permitida,
    Item
FROM 
    RDR1
WHERE
    "DocEntry" = DocEntrey AND "LineNum" = line_num;

SELECT 
    SUM("Quantity")
    INTO
    Quantidade_Faturada    
FROM 
    "INV1" T0
    JOIN "OINV" T1 ON T1."DocEntry" = T0."DocEntry"
WHERE
    T1."CANCELED" = 'N' AND T0."BaseType" = '17' AND T0."BaseEntry" = DocEntrey AND T0."BaseLine" =  line_num;
    
SELECT 
    SUM(T0."Quantity")
    INTO
    Quantidade_Devolvida    
FROM 
    "RIN1" T0
    JOIN "ORIN" T1 ON T1."DocEntry" = T0."DocEntry"
    JOIN "INV1" T2 ON T0."BaseType" = '13' AND T0."BaseEntry" = T2."DocEntry" AND T0."BaseLine" =  T2."LineNum"
WHERE
    T1."CANCELED" = 'N' AND T2."BaseType" = '13' AND T2."BaseEntry" = DocEntrey AND T2."BaseLine" =  line_num;


IF IFNULL(Quantidade_Permitida,0) - IFNULL(Quantidade_Faturada,0) + IFNULL(Quantidade_Devolvida,0)< 0 THEN
    error_message := CONCAT('Quantidade não permitida para o item ', Item);
--    error_message := IFNULL(Quantidade_Permitida,0) - IFNULL(Quantidade_Faturada,0) - IFNULL(quantidade,0)  + IFNULL(Quantidade_Devolvida,0);
END IF;

result := error_message;
        
END;