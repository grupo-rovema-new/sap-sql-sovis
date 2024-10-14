CREATE OR REPLACE FUNCTION "Get_Pedido_Venda_Permissao_Faturamento"(DocEntrey integer, line_num integer, quantidade float ) RETURNS result NVARCHAR(200) LANGUAGE SQLSCRIPT AS


BEGIN

    DECLARE error_message NVARCHAR(200);   
    DECLARE Quantidade_Permitida float; 
    DECLARE Quantidade_Faturada float; 
    DECLARE Quantidade_Pedido float;        
    DECLARE Item NVARCHAR(255);
    
    error_message := 'Ok';
    
    SELECT 
        SUM("OpenCreQty"),
        "ItemCode",
        "Quantity"
    INTO 
        Quantidade_Permitida,
        Item,
        Quantidade_Pedido        
    FROM 
        "RDR1"
    WHERE 
        "DocEntry" = DocEntrey AND "LineNum" = line_num
    GROUP BY        
        "ItemCode",
        "Quantity";
       
    SELECT 
        SUM("Quantity")
    INTO 
        Quantidade_Faturada
    FROM 
        "INV1" T0
    JOIN 
        "OINV" T1 ON T1."DocEntry" = T0."DocEntry"
    WHERE 
        T1."CANCELED" = 'N' 
        AND T0."BaseType" = '17' 
        AND T0."BaseEntry" = DocEntrey 
        AND T0."BaseLine" = line_num;

     IF IFNULL(Quantidade_Faturada, 0) > IFNULL(Quantidade_Pedido,0) THEN
        error_message := CONCAT('Quantidade não permitida para o item ', Item);
    END IF;

    result := error_message;

END;