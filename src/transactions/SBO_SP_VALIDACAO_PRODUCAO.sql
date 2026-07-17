CREATE OR replace PROCEDURE SBO_SP_VALIDACAO_PRODUCAO

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
BEGIN
	
IF :object_type IN('202') THEN
	DECLARE idade INT;
    DECLARE temEntrada INT;
	DECLARE temSaida INT;
	DECLARE ItemCode nvarchar (255);
	DECLARE docNumMsg INT;  
/*
 * Anotações
 * Status (L ->  Encerrado, R ->  Liberado, P -> Planejado)
 */
	
	SELECT DISTINCT 
		DAYS_BETWEEN("CreateDate", CURRENT_DATE),
		entrada."DocEntry" AS "temEntrada?",
		saida."DocEntry" AS "temSaida?"
	INTO idade, temEntrada, temSaida
	FROM
		"OWOR" ordem
		LEFT JOIN "IGN1" entrada ON(entrada."BaseRef" = to_char(ordem."DocNum"))
		LEFT JOIN "IGE1" saida ON(saida."BaseRef" = to_char(ordem."DocNum"))
	WHERE
		"CreateDate" >= '2025-01-01'
		AND ordem."DocEntry" = :list_of_cols_val_tab_del LIMIT 1;

	IF :transaction_type = 'A' THEN

		-- Regra 1: item sem Id Integração vinculado (nunca seria localizada como pendente no sysfeed)
		IF EXISTS (
			SELECT 1
			FROM "OWOR" O
			LEFT JOIN "OITT" F ON F."Code" = O."ItemCode"
			WHERE O."DocEntry" = :list_of_cols_val_tab_del
			  AND O."Type" = 'S'
			  AND O."ItemCode" NOT LIKE 'PAC%'
			  AND F."U_LbrOne_Id" IS NULL
		) THEN
			error := '7';
			error_message := 'Ação bloqueada: preencha o campo Id Integração na tela Estrutura do Produto deste item com o código da fórmula no sysfeed antes de liberar a ordem de produção.';
		END IF;

		-- Regra 2: campos de controle do sysfeed já preenchidos na criação (só o fluxo de integração deve gravá-los)
		IF EXISTS (
			SELECT 1
			FROM "OWOR" O
			WHERE O."DocEntry" = :list_of_cols_val_tab_del
			  AND O."Type" = 'S'
			  AND (
					(O."U_sysfeed_status" IS NOT NULL AND O."U_sysfeed_status" <> '' AND O."U_sysfeed_status" <> 'PENDENTE')
				 OR (O."U_sysfeed_numero" IS NOT NULL AND O."U_sysfeed_numero" <> '')
				 OR O."U_LbrOne_DtIntegracao" IS NOT NULL
				 OR O."U_LbrOne_HrIntegracao" IS NOT NULL
			  )
		) THEN
			error := '7';
			error_message := 'Ação bloqueada: os campos de controle da integração sysfeed (Status Sysfeed / Numero Sysfeed / Dt e Hr atualização Integração) não podem vir preenchidos na criação da ordem de produção.';
		END IF;

	END IF;

	IF :transaction_type IN ('A','U') THEN

		-- Trava: OP liberada sem batelada nunca sobe para o sysfeed (backend pula a linha)
		IF EXISTS (
			SELECT 1
			FROM "OWOR" O
			INNER JOIN "OITT" F ON F."Code" = O."ItemCode"
			WHERE O."DocEntry" = :list_of_cols_val_tab_del
			  AND O."Type" = 'S'
			  AND O."Status" = 'R'
			  AND F."U_LbrOne_Id" IS NOT NULL
			  AND IFNULL(O."U_LbrOne_Batelada", 0) <= 0
		) THEN
			error := '7';
			error_message := 'Ação bloqueada: preencha o campo Batelada da ordem de produção antes de liberá-la.';
		END IF;

	END IF;

	IF :transaction_type = 'U' THEN

		-- Trava: campos de controle do sysfeed devem ser gravados pela integração, sempre em par consistente
		IF EXISTS (
			SELECT 1
			FROM "OWOR" O
			WHERE O."DocEntry" = :list_of_cols_val_tab_del
			  AND O."Type" = 'S'
			  AND O."CreateDate" >= '2026-07-14'
			  AND (
					(O."U_sysfeed_status" IN ('ENVIADO','DUPLICADO') AND O."U_LbrOne_DtIntegracao" IS NULL)
				 OR ((O."U_sysfeed_status" IS NULL OR O."U_sysfeed_status" = '' OR O."U_sysfeed_status" IN ('PENDENTE','ERRO','PARCIAL'))
					 AND O."U_LbrOne_DtIntegracao" IS NOT NULL)
			  )
		) THEN
			error := '7';
			error_message := 'Ação bloqueada: Status Sysfeed inconsistente com a Dt atualização Integração. Esses campos são preenchidos pela integração e não devem ser alterados manualmente.';
		END IF;

		-- Trava: Numero Sysfeed só existe legitimamente junto de status de sucesso (integração sempre zera o número em qualquer outro status)
		IF EXISTS (
			SELECT 1
			FROM "OWOR" O
			WHERE O."DocEntry" = :list_of_cols_val_tab_del
			  AND O."Type" = 'S'
			  AND O."CreateDate" >= '2026-07-14'
			  AND O."U_sysfeed_numero" IS NOT NULL AND O."U_sysfeed_numero" <> ''
			  AND (O."U_sysfeed_status" IS NULL OR O."U_sysfeed_status" = '' OR O."U_sysfeed_status" IN ('PENDENTE','ERRO','PARCIAL'))
		) THEN
			error := '7';
			error_message := 'Ação bloqueada: Numero Sysfeed preenchido sem Status Sysfeed de sucesso (Enviado/Duplicado). Esse campo é preenchido pela integração e não deve ser alterado manualmente.';
		END IF;

		-- Trava: só é permitido apagar o Numero Sysfeed junto com o reset completo (status não-sucesso e Dt/Hr Integração vazias)
		IF EXISTS (
			SELECT 1
			FROM "OWOR" O
			WHERE O."DocEntry" = :list_of_cols_val_tab_del
			  AND O."Type" = 'S'
			  AND O."CreateDate" >= '2026-07-14'
			  AND (O."U_sysfeed_numero" IS NULL OR O."U_sysfeed_numero" = '')
			  AND NOT (
					(O."U_sysfeed_status" IS NULL OR O."U_sysfeed_status" = '' OR O."U_sysfeed_status" IN ('PENDENTE','ERRO','PARCIAL'))
				AND O."U_LbrOne_DtIntegracao" IS NULL
				AND O."U_LbrOne_HrIntegracao" IS NULL
			  )
		) THEN
			error := '7';
			error_message := 'Ação bloqueada: não é permitido remover o Numero Sysfeed.';
		END IF;

	END IF;

	-- Bloqueia modificar novos se existir ordem velhas planejada ou liberadas
	IF(idade < 20 AND EXISTS(
		SELECT
			"DocNum"
		FROM
			"OWOR"
		WHERE
			"Status" in('R','P')
			AND "CreateDate" >= '2025-01-01'
			AND DAYS_BETWEEN("CreateDate", CURRENT_DATE) > 20
		LIMIT 1)) THEN
			SELECT
				"DocNum"
			INTO docNumMsg
			FROM
				"OWOR"
			WHERE
				"Status" in('R','P')
				AND "CreateDate" >= '2025-01-01'
				AND DAYS_BETWEEN("CreateDate", CURRENT_DATE) > 20
			LIMIT 1;
			error := '88';
			error_message := 'Ação bloqueada pois existe ordens de produção abertas com mais de 30 dais '|| docNumMsg;
	END if;


	IF((temEntrada IS NULL OR temSaida IS NULL) AND EXISTS(
		SELECT
			ordem."DocNum",
			DAYS_BETWEEN("CreateDate", CURRENT_DATE) AS IDADE_EM_DIAS,
			entrada."DocEntry" AS "temEntrada?",
			saida."DocEntry" AS "temSaida?"
		FROM
			"OWOR" ordem
			LEFT JOIN "IGN1" entrada ON(entrada."BaseRef" = to_char(ordem."DocNum"))
			LEFT JOIN "IGE1" saida ON(saida."BaseRef" = to_char(ordem."DocNum"))
		WHERE
			"Status" in('R')
			AND "CreateDate" >= '2025-01-01' 
			AND DAYS_BETWEEN("CreateDate", CURRENT_DATE) > 3
			AND ordem."DocEntry" <> :list_of_cols_val_tab_del
			AND ((entrada."DocEntry" IS NOT NULL AND saida."DocEntry" IS NULL) OR (entrada."DocEntry" IS NULL AND saida."DocEntry" IS NOT NULL)))) 
	    THEN
			SELECT
				ordem."DocNum"
				INTO docNumMsg 
			FROM
				"OWOR" ordem
				LEFT JOIN "IGN1" entrada ON(entrada."BaseRef" = to_char(ordem."DocNum"))
				LEFT JOIN "IGE1" saida ON(saida."BaseRef" = to_char(ordem."DocNum"))
			WHERE
				"Status" in('R')
				AND "CreateDate" >= '2025-01-01' 
				AND DAYS_BETWEEN("CreateDate", CURRENT_DATE) > 3
				AND ((entrada."DocEntry" IS NOT NULL AND saida."DocEntry" IS NULL) OR (entrada."DocEntry" IS NULL AND saida."DocEntry" IS NOT NULL)) LIMIT 1;
			error := '88';
			error_message := 'Ação bloqueada porque existe ordens com lancamentos parciais (so entrada ou so saida) '|| docNumMsg;
	END if;


	IF( EXISTS(
		SELECT
			ordem."DocNum",
			DAYS_BETWEEN("CreateDate", CURRENT_DATE) AS IDADE_EM_DIAS
		FROM
			"OWOR" ordem
			LEFT JOIN "IGN1" entrada ON(entrada."BaseRef" = to_char(ordem."DocNum"))
			LEFT JOIN "IGE1" saida ON(saida."BaseRef" = to_char(ordem."DocNum"))
		WHERE
			"Status" in('L')
			AND ((entrada."DocEntry" IS NOT NULL AND saida."DocEntry" IS NULL) OR (entrada."DocEntry" IS NULL AND saida."DocEntry" IS NOT NULL))
			AND ordem."DocEntry" 	= :list_of_cols_val_tab_del)) THEN
		error := '88';
		error_message := 'Não é permitido encerrar a ordem de produção sem informar entradas e saidas dos itens.';
	END if;
IF EXISTS (
    SELECT
        1
    FROM OWOR O
    INNER JOIN WOR1 LP
        ON O."DocEntry" = LP."DocEntry"
    INNER JOIN OITT R
        ON O."ItemCode" = R."Code"
    INNER JOIN ITT1 RL
        ON RL."Father"   = R."Code"
       AND LP."ItemCode" = RL."Code"
    WHERE
        LP."BaseQty" >= 2 * RL."Quantity"
      AND O."DocEntry" = :list_of_cols_val_tab_del
    LIMIT 1
) THEN
    SELECT
        LP."ItemCode"
    INTO
        ItemCode
    FROM OWOR O
    INNER JOIN WOR1 LP
        ON O."DocEntry" = LP."DocEntry"
    INNER JOIN OITT R
        ON O."ItemCode" = R."Code"
    INNER JOIN ITT1 RL
        ON RL."Father"   = R."Code"
       AND LP."ItemCode" = RL."Code"
    WHERE
        LP."BaseQty" >= 2 * RL."Quantity"
      AND O."DocEntry" = :list_of_cols_val_tab_del
    LIMIT 1;

    error         := '7';
    error_message := 'Quantidade base muito diferente da receita no item ' || ItemCode;
END IF;
END IF;
IF :object_type IN('59') THEN

    IF EXISTS (
        SELECT 1
        FROM IGN1 o
        INNER JOIN owor ordem
            ON ordem."DocNum" = CAST(o."BaseRef" AS INT)
        WHERE o."DocEntry" = :list_of_cols_val_tab_del 
          AND o."BaseRef" <> ''
          AND NOT EXISTS (
              SELECT 1 FROM IGE1 WHERE "BaseRef" = CAST(ordem."DocNum" AS NVARCHAR)
          )
    ) THEN 
        error := '7';
        error_message := 'Primeiro deve ser realizado a saida de mecadoria';
    END IF;

END IF;

END;
