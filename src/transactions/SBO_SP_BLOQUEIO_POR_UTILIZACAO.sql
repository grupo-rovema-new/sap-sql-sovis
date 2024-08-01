CREATE OR REPLACE PROCEDURE SBO_SP_VALIDACAO_POR_UTILIZACAO
(
    in object_type nvarchar(30),                 -- SBO Object Type
    in transaction_type nchar(1),                -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
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
utilizacao int;
filial int;
pTblSuffix nvarchar(4);
pTblPrefix nvarchar(4);
query nvarchar(255);
futura nvarchar(4); --Verificar se a nota é futura
xcount int;

BEGIN

    utilizacao := 0;
    filial := 0;
    pTblSuffix := '-1'; 
    xcount := 0;
    pTblPrefix := '';
    futura := '';

    IF object_type = '13' THEN -- NOTA FISCAL DE SAÍDA
        pTblSuffix := 'OINV';
        pTblPrefix := 'INV1';
    ELSEIF object_type = '14' THEN -- DEVOLUÇÃO DE NOTA FISCAL DE SAÍDA
        pTblSuffix := 'ORIN';
        pTblPrefix := 'RIN1';
    ELSEIF object_type = '15' THEN -- ENTREGA
        pTblSuffix := 'ODLN';
        pTblPrefix := 'DLN1';
    ELSEIF object_type = '16' THEN -- DEVOLUÇÃO DE ENTREGA
        pTblSuffix := 'ORDN';
        pTblPrefix := 'RDN1';
    ELSEIF object_type = '18' THEN -- NOTA FISCAL DE ENTRADA
        pTblSuffix := 'OPCH';
        pTblPrefix := 'PCH1';
    ELSEIF object_type = '19' THEN -- DEVOLUÇÃO DE NOTA FISCAL DE ENTRADA
        pTblSuffix := 'ORPC';
        pTblPrefix := 'RPC1';
    ELSEIF object_type = '20' THEN -- RECEBIMENTO DE MERCADORIA
        pTblSuffix := 'OPDN';
        pTblPrefix := 'PDN1';
    ELSEIF object_type = '21' THEN -- DEVOLUÇÃO DE MERCADORIA
        pTblSuffix := 'ORPD';
        pTblPrefix := 'RPD1';
    END IF;

    IF pTblSuffix <> '-1' THEN
        query := 'SELECT OBJETO."BPLId", LINHA."Usage", OBJETO."isIns" FROM ' || pTblSuffix || ' OBJETO INNER JOIN ' || pTblPrefix || ' LINHA ON OBJETO."DocEntry" = LINHA."DocEntry" WHERE OBJETO."DocEntry" = ' || :list_of_cols_val_tab_del;

        EXECUTE IMMEDIATE query INTO filial, utilizacao, futura;

        IF futura = 'N' THEN
            IF NOT EXISTS (
                SELECT 
                    1
                FROM 
                    "@BLOQUEIOUTILIZACAO" b 
                INNER JOIN 
                    "@FILIAISBLOQUEIO" FB 
                ON 
                    b."DocEntry" = FB."DocEntry"
                INNER JOIN 
                    "@UTILIZACOES" U 
                ON 
                    b."DocEntry" = U."DocEntry"
                WHERE 
                    SUBSTRING(b."U_TipoDocumento", 1, INSTR(b."U_TipoDocumento", '-') - 1) = object_type 
                    AND SUBSTRING(FB."U_Filial", 1, INSTR(FB."U_Filial", '-') - 1) = filial
                    AND SUBSTRING(U."U_Utilizacao", 1, INSTR(U."U_Utilizacao", '-') - 1) = utilizacao
                    AND (SUBSTRING(b."U_TipoDocumento", 
                        INSTR(b."U_TipoDocumento", '-') + 1, 
                        INSTR(b."U_TipoDocumento", '-', INSTR(b."U_TipoDocumento", '-') + 1) - INSTR(b."U_TipoDocumento", '-') - 1) = 'A'
                    OR SUBSTRING(b."U_TipoDocumento", 
                        INSTR(b."U_TipoDocumento", '-') + 1, 
                        INSTR(b."U_TipoDocumento", '-', INSTR(b."U_TipoDocumento", '-') + 1) - INSTR(b."U_TipoDocumento", '-') - 1) = ''
                    )
            ) THEN
                error_message := 'Essa utilização não é permitida neste módulo. Favor procurar o setor fiscal!';
                error := 7;    
            END IF;
        ELSEIF futura = 'Y' THEN
            IF NOT EXISTS (
                SELECT 
                    1
                FROM 
                    "@BLOQUEIOUTILIZACAO" b 
                INNER JOIN 
                    "@FILIAISBLOQUEIO" FB 
                ON 
                    b."DocEntry" = FB."DocEntry"
                INNER JOIN 
                    "@UTILIZACOES" U 
                ON 
                    b."DocEntry" = U."DocEntry"
                WHERE 
                    SUBSTRING(b."U_TipoDocumento", 1, INSTR(b."U_TipoDocumento", '-') - 1) = object_type 
                    AND SUBSTRING(FB."U_Filial", 1, INSTR(FB."U_Filial", '-') - 1) = filial
                    AND SUBSTRING(U."U_Utilizacao", 1, INSTR(U."U_Utilizacao", '-') - 1) = utilizacao
                    AND SUBSTRING(b."U_TipoDocumento", 
                        INSTR(b."U_TipoDocumento", '-') + 1, 
                        INSTR(b."U_TipoDocumento", '-', INSTR(b."U_TipoDocumento", '-') + 1) - INSTR(b."U_TipoDocumento", '-') - 1) = 'B'
            ) THEN
                error_message := 'Essa utilização não é permitida neste módulo. Favor procurar o setor fiscal!';
                error := 7;    
            END IF;
        END IF;
    END IF;

END;
