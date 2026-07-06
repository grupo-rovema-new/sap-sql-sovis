CREATE OR REPLACE PROCEDURE SBO_SP_VALIDACAO_VENDA

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

DECLARE valorNegociado number;
DECLARE totalDocumento number;

-- Garante que o total do documento (produtos, sem frete) bata com o valor negociado.
-- Se divergir, o calculo de imposto desonerado nao fechou no preco negociado.
-- So valida quando o sistema ja confirmou o calculo de imposto (U_pedido_update = '0');
-- enquanto U_pedido_update = '1' o documento ainda esta pendente de calculo pelo job.

-- Pedido de venda (ORDR)
IF :object_type IN('17') AND :transaction_type IN('A') then

	SELECT
		sum(COALESCE(NULLIF(linha."U_preco_negociado", 0) * linha."Quantity", linha."LineTotal")),
		max(COALESCE(cab."DocTotal", 0) - COALESCE(cab."TotalExpns", 0))
	INTO
		valorNegociado, totalDocumento
	FROM
		"ORDR" cab
		INNER JOIN "RDR1" linha ON linha."DocEntry" = cab."DocEntry"
	WHERE
		cab."DocEntry" = :list_of_cols_val_tab_del
		AND COALESCE(cab."U_pedido_update", '0') <> '1'
		AND EXISTS(SELECT 1 FROM "RDR1" WHERE "DocEntry" = cab."DocEntry" AND "U_preco_negociado" > 0);

	IF valorNegociado IS NOT NULL AND abs(valorNegociado - totalDocumento) > 0.01 THEN
		error := 88;
    	error_message := 'O total do documento diverge do valor negociado. Esperado '|| valorNegociado;
	END if;
END IF;

-- Nota fiscal de saida (OINV)
IF :object_type IN('13') AND :transaction_type IN('A') then

	SELECT
		sum(COALESCE(NULLIF(linha."U_preco_negociado", 0) * linha."Quantity", linha."LineTotal")),
		max(COALESCE(cab."DocTotal", 0) - COALESCE(cab."TotalExpns", 0))
	INTO
		valorNegociado, totalDocumento
	FROM
		"OINV" cab
		INNER JOIN "INV1" linha ON linha."DocEntry" = cab."DocEntry"
	WHERE
		cab."DocEntry" = :list_of_cols_val_tab_del
		AND COALESCE(cab."U_pedido_update", '0') <> '1'
		AND EXISTS(SELECT 1 FROM "INV1" WHERE "DocEntry" = cab."DocEntry" AND "U_preco_negociado" > 0);

	IF valorNegociado IS NOT NULL AND abs(valorNegociado - totalDocumento) > 0.01 THEN
		error := 88;
    	error_message := 'O total do documento diverge do valor negociado. Esperado '|| valorNegociado;
	END if;
END IF;

END;
