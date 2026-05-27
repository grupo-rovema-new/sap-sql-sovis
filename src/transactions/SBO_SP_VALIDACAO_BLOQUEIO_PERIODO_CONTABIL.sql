CREATE OR REPLACE PROCEDURE SBO_SP_Validacao_Bloqueio_Periodo_Contabil
(
    IN object_type NVARCHAR(30),
    IN transaction_type NCHAR(1),
    IN num_of_cols_in_key INT,
    IN list_of_key_cols_tab_del NVARCHAR(255),
    IN list_of_cols_val_tab_del NVARCHAR(255),
    INOUT error INT,
    INOUT error_message NVARCHAR(200)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
    mes_data   INT;
    ano_data   INT;
    filial     INT;

    pTblSuffix NVARCHAR(4);
    query      NVARCHAR(2000);

    v_user_id  INT;          
    v_locked   NVARCHAR(1);
    v_status   NVARCHAR(1);
BEGIN

    mes_data := 0;
    ano_data := 0;
    filial   := 0;
    pTblSuffix := '-1';
    v_user_id := 0;

    IF :object_type = '13' THEN pTblSuffix := 'OINV'; END IF; -- NF Saída
    IF :object_type = '14' THEN pTblSuffix := 'ORIN'; END IF; -- Dev. NF Saída
    IF :object_type = '15' THEN pTblSuffix := 'ODLN'; END IF; -- Entrega
    IF :object_type = '16' THEN pTblSuffix := 'ORDN'; END IF; -- Dev. Entrega
    IF :object_type = '18' THEN pTblSuffix := 'OPCH'; END IF; -- NF Entrada
    IF :object_type = '19' THEN pTblSuffix := 'ORPC'; END IF; -- Dev. NF Entrada
    IF :object_type = '20' THEN pTblSuffix := 'OPDN'; END IF; -- Receb. Mercadoria
    IF :object_type = '21' THEN pTblSuffix := 'ORPD'; END IF; -- Dev. Mercadoria
    IF :object_type = '60' THEN pTblSuffix := 'OIGE'; END IF; -- Saída Mercadoria
    IF :object_type = '59' THEN pTblSuffix := 'OIGN'; END IF; -- Entrada Mercadoria
    IF :object_type = '46' THEN pTblSuffix := 'OVPM'; END IF; -- Contas a Pagar
    IF :object_type = '24' THEN pTblSuffix := 'ORCT'; END IF; -- Contas a Receber
    IF :object_type = '30' THEN pTblSuffix := 'OJDT'; END IF; -- LCM
    IF :object_type = '67' THEN pTblSuffix := 'OWTR'; END IF; -- Transferência
	IF :object_type = '162' THEN pTblSuffix := 'OMRV'; END IF; -- REAVALIAÇAO DE ESTOQUE
    -- Documentos (não OJDT)
    IF :object_type <> '30' AND :pTblSuffix <> '-1' THEN

        query :=
            'SELECT MONTH("DocDate"), YEAR("DocDate"), "BPLId", "UserSign" ' ||
            'FROM ' || :pTblSuffix || ' ' ||
            'WHERE "DocEntry" = ' || :list_of_cols_val_tab_del;

        EXECUTE IMMEDIATE :query INTO mes_data, ano_data, filial, v_user_id;

        -- Bloqueio especial para manager
        IF :v_user_id = 1 THEN
            SELECT TOP 1  "PeriodStat"
              INTO  v_status
              FROM OFPR
             WHERE :mes_data = MONTH("F_RefDate")
               AND :ano_data = YEAR("F_RefDate");

            IF :v_status <> 'N' THEN
                error := 7;
                error_message := 'Período bloqueado para essa data e para essa empresa. Favor procurar o setor contábil.';
            END IF;
        END IF;

        IF EXISTS (
            SELECT 1
              FROM "@RO_PERIODO_CONTABIL"
             WHERE "U_Mes"     = :mes_data
               AND "U_Ano"     = :ano_data     
               AND "U_Empresa" = :filial
               AND "U_Status"  = '1'
        ) THEN
            error := 1;
            error_message := 'Período bloqueado para essa data e para essa empresa. Favor procurar o setor contábil.';
        END IF;

    END IF;

    -- LCM (OJDT)
    IF :object_type = '30' AND :transaction_type <> 'U' THEN

        query :=
            'SELECT DISTINCT MONTH(T0."RefDate"), YEAR(T0."RefDate"), T2."BPLId" ' ||
            'FROM "OJDT" T0 ' ||
            'INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" ' ||
            'INNER JOIN OBPL T2 ON T1."BPLId" = T2."BPLId" ' ||
            'WHERE T0."TransId" = ' || :list_of_cols_val_tab_del;

        EXECUTE IMMEDIATE :query INTO mes_data, ano_data, filial;

        IF EXISTS (
            SELECT 1
              FROM "@RO_PERIODO_CONTABIL"
             WHERE "U_Mes"     = :mes_data
               AND "U_Ano"     = :ano_data
               AND "U_Empresa" = :filial
               AND "U_Status"  = '1'
        ) THEN
            error := 1;
            error_message := 'Período bloqueado para essa data e para essa empresa. Favor procurar o setor contábil.';
        END IF;

    END IF;

END;
