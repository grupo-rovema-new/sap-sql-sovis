CREATE OR REPLACE PROCEDURE SBO_SP_Validacao_Duplicidade_Seq_Serial_Serie
(
    IN  object_type                 NVARCHAR(30),  -- SBO Object Type
    IN  transaction_type            NCHAR(1),      -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    IN  num_of_cols_in_key          INT,
    IN  list_of_key_cols_tab_del    NVARCHAR(255),
    IN  list_of_cols_val_tab_del    NVARCHAR(255),
    INOUT error                     INT,
    INOUT error_message             NVARCHAR(200)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS

    pTblSuffix      NVARCHAR(4);
    query           NVARCHAR(1000);

    vSeqCode        NVARCHAR(50);
    vSerial         NVARCHAR(50);
    vSeriesStr      NVARCHAR(50);

    xcount_total    INT;

BEGIN

    -------------------------------------------------------------------
    -- Só roda em ADD / UPDATE
    -------------------------------------------------------------------
    IF :transaction_type NOT IN ('A','U') THEN
        RETURN;
    END IF;

    -------------------------------------------------------------------
    -- Se a lista de valores vier vazia ou NULL, não faz nada
    -------------------------------------------------------------------
    IF :list_of_cols_val_tab_del IS NULL OR :list_of_cols_val_tab_del = '' THEN
        RETURN;
    END IF;

    -------------------------------------------------------------------
    -- Mapeia tabela pelo object_type
    -------------------------------------------------------------------
    pTblSuffix := '-1';

    IF :object_type = '13' THEN       -- NF SAÍDA
        pTblSuffix := 'OINV';
    END IF;

    IF :object_type = '14' THEN       -- DEVOLUÇÃO NF SAÍDA
        pTblSuffix := 'ORIN';
    END IF;

    IF :object_type = '15' THEN       -- ENTREGA
        pTblSuffix := 'ODLN';
    END IF;

    IF :object_type = '16' THEN       -- DEVOLUÇÃO ENTREGA
        pTblSuffix := 'ORDN';
    END IF;
/*
    IF :object_type = '18' THEN       -- NF ENTRADA
        pTblSuffix := 'OPCH';
    END IF;
*/
    IF :object_type = '19' THEN       -- DEVOLUÇÃO NF ENTRADA
        pTblSuffix := 'ORPC';
    END IF;

    IF :object_type = '20' THEN       -- RECEBIMENTO MERCADORIA
        pTblSuffix := 'OPDN';
    END IF;

    IF :object_type = '21' THEN       -- DEVOLUÇÃO MERCADORIA
        pTblSuffix := 'ORPD';
    END IF;

    -- Se não for nenhum desses objetos, não valida
    IF pTblSuffix = '-1' THEN
        RETURN;
    END IF;

    -------------------------------------------------------------------
    -- 1) Lê SeqCode / Serial / SeriesStr do documento atual (não cancelado)
    -------------------------------------------------------------------
    vSeqCode   := NULL;
    vSerial    := NULL;
    vSeriesStr := NULL;

	   query := '
	    SELECT 
	        MAX(TO_NVARCHAR("SeqCode")),
	        MAX(TO_NVARCHAR("Serial")),
	        MAX(TO_NVARCHAR("SeriesStr"))
	    FROM "' || pTblSuffix || '"
	    WHERE "CANCELED" = ''N''
	      AND "DocEntry" = ' || :list_of_cols_val_tab_del;
	      
	EXECUTE IMMEDIATE query INTO vSeqCode, vSerial, vSeriesStr;


    -- Se não tiver numeração, não valida
    IF vSeqCode IS NULL OR vSerial IS NULL OR vSeriesStr IS NULL THEN
        RETURN;
    END IF;

    -------------------------------------------------------------------
    -- 2) Conta quantos documentos NÃO CANCELADOS (em todas as tabelas)
    --    têm a mesma combinação SeqCode / Serial / SeriesStr
    --    Se der > 1 → existe pelo menos outro documento além desse
    -------------------------------------------------------------------
    SELECT COUNT(*)
      INTO xcount_total
    FROM (
        SELECT 
            TO_NVARCHAR("SeqCode")   AS "SeqCode",
            TO_NVARCHAR("Serial")    AS "Serial",
            TO_NVARCHAR("SeriesStr") AS "SeriesStr"
        FROM "OINV"
        WHERE "CANCELED" = 'N'
        UNION ALL
        SELECT 
            TO_NVARCHAR("SeqCode"),
            TO_NVARCHAR("Serial"),
            TO_NVARCHAR("SeriesStr")
        FROM "ORIN"
        WHERE "CANCELED" = 'N'
        UNION ALL
        SELECT 
            TO_NVARCHAR("SeqCode"),
            TO_NVARCHAR("Serial"),
            TO_NVARCHAR("SeriesStr")
        FROM "ODLN"
        WHERE "CANCELED" = 'N'
        UNION ALL
        SELECT 
            TO_NVARCHAR("SeqCode"),
            TO_NVARCHAR("Serial"),
            TO_NVARCHAR("SeriesStr")
        FROM "ORDN"
        WHERE "CANCELED" = 'N'
        AND  "SeqCode" NOT IN (-2,-1)
        UNION ALL
        /*SELECT 
            TO_NVARCHAR("SeqCode"),
            TO_NVARCHAR("Serial"),
            TO_NVARCHAR("SeriesStr")
        FROM "OPCH"
        WHERE "CANCELED" = 'N'
        AND  "SeqCode" NOT IN (-2,-1)
        UNION ALL*/
        SELECT 
            TO_NVARCHAR("SeqCode"),
            TO_NVARCHAR("Serial"),
            TO_NVARCHAR("SeriesStr")
        FROM "ORPC"
        WHERE "CANCELED" = 'N'
        UNION ALL
        SELECT 
            TO_NVARCHAR("SeqCode"),
            TO_NVARCHAR("Serial"),
            TO_NVARCHAR("SeriesStr")
        FROM "OPDN"
        WHERE "CANCELED" = 'N'
        AND  "SeqCode" NOT IN (-2,-1)
        UNION ALL
        SELECT 
            TO_NVARCHAR("SeqCode"),
            TO_NVARCHAR("Serial"),
            TO_NVARCHAR("SeriesStr")
        FROM "ORPD"
        WHERE "CANCELED" = 'N'
    ) T
    WHERE T."SeqCode"   = :vSeqCode
      AND T."Serial"    = :vSerial
      AND T."SeriesStr" = :vSeriesStr;

    -------------------------------------------------------------------
    -- 3) Se tem mais de 1 doc com a mesma combinação → trava
    -------------------------------------------------------------------
    IF :xcount_total > 1 THEN
        error := 1;
        error_message := 'Já existe documento fiscal (não cancelado, em algum módulo) com a mesma combinação SeqCode/Serial/Serie. Verifique a numeração da NF-e.';
    END IF;

END;
