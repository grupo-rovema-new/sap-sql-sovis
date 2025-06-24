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
		"CreateDate" >= '2025-06-01'
		AND ordem."DocEntry" = :list_of_cols_val_tab_del LIMIT 1;

	-- Bloqueia modificar novos se existir ordem velhas planejada ou liberadas
	IF(idade < 20 AND EXISTS(
		SELECT
			"DocNum"
		FROM
			"OWOR"
		WHERE
			"Status" in('R','P')
			AND "CreateDate" >= '2025-06-01'
			AND DAYS_BETWEEN("CreateDate", CURRENT_DATE) > 20
		LIMIT 1)) THEN
			SELECT
				"DocNum"
			INTO docNumMsg
			FROM
				"OWOR"
			WHERE
				"Status" in('R','P')
				AND "CreateDate" >= '2025-06-01'
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
			AND "CreateDate" >= '2025-06-01' 
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
				AND "CreateDate" >= '2025-06-01' 
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
