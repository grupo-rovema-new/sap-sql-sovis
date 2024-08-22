CREATE OR REPLACE VIEW NOTASENTRADA AS
SELECT
	T0."DocEntry",
	T0."DocNum",
	T0."CardCode",
	T0."CardName" AS "Paceiro de Negocio",
	T0."Serial" AS "Nº NF",
	T0."SeriesStr" AS "Serie",
	T0."DocTotal" AS "Total da Nota",
	CASE
		WHEN T0."DocStatus" = 'C'
		AND T0."CANCELED" = 'Y'
		OR T0."CANCELED" = 'C' THEN 'Cancelado'
		WHEN T0."PaidSum" = T0."DocTotal" THEN 'Pago'
		WHEN T0."PaidSum" < T0."DocTotal"
		AND T0."PaidSum" <> 0 THEN 'Pago parcial'
		ELSE 'Aberto'
	END AS "Status",
	T0."DocDate" AS "Data de lançamento",
	T0."BPLId",
	T2."USER_CODE",
	T2."U_NAME" AS "Colaborador",
	T0."BPLName" AS "Filial",
	T0."DocDueDate" AS "Data de Vencimento",
	'Nota de entrada' AS "Tipo de documento",
	"TaxDate" AS "Data de emissão",
	(
	SELECT
		MAX(T2."Usage")
	FROM
		PCH1
	INNER JOIN OUSG T2 ON
		PCH1."Usage" = T2."ID"
	WHERE
		PCH1."DocEntry" = T0."DocEntry") AS "Utiliazação",
	(
	SELECT
		MAX(T2."ID")
	FROM
		PCH1
	INNER JOIN OUSG T2 ON
		PCH1."Usage" = T2."ID"
	WHERE
		PCH1."DocEntry" = T0."DocEntry") AS "IDUtil",
	T1."OcrCode2" AS "Centro de custo",
	CC."PrcName" AS "Nome centro de custo",
	C."AcctCode" AS "Conta",
	C."AcctName" AS "Nome da conta"
FROM
	OPCH T0
INNER JOIN PCH1 T1 ON
	T0."DocEntry" = T1."DocEntry"
INNER JOIN OUSR T2 ON
	T0."UserSign" = T2."USERID"
INNER JOIN OPRC CC ON
	CC."PrcCode" = T1."OcrCode2"
INNER JOIN OACT C ON
	T1."AcctCode" = C."AcctCode"
WHERE
	T0."CANCELED" <> 'C'
UNION 

SELECT
	T0."DocEntry",
	T0."DocNum",
	T0."CardCode",
	T0."CardName" AS "Paceiro de Negocio",
	T0."Serial" AS "Nº NF",
	T0."SeriesStr" AS "Serie",
	T0."DocTotal" AS "Total da Nota",
	CASE
		WHEN T0."DocStatus" = 'C'
		AND T0."CANCELED" = 'Y'
		OR T0."CANCELED" = 'C' THEN 'Cancelado'
		ELSE 'Aberto'
	END AS "Status",
	T0."DocDate" AS "Data de lançamento",
	T0."BPLId",
	T1."USER_CODE",
	T1."U_NAME" AS "Colaborador",
	T0."BPLName" AS "Filial",
	T0."DocDueDate" AS "Data de Vencimento",
	'Recebimento de mercadoria' AS "Tipo de documento",
	"TaxDate" AS "Data de emissão",
	(
	SELECT
		MAX(T2."Usage")
	FROM
		PDN1
	INNER JOIN OUSG T2 ON
		PDN1."Usage" = T2."ID"
	WHERE
		PDN1."DocEntry" = T0."DocEntry") AS "Utilização",
	(
	SELECT
		MAX(T2."ID")
	FROM
		PDN1
	INNER JOIN OUSG T2 ON
		PDN1."Usage" = T2."ID"
	WHERE
		PDN1."DocEntry" = T0."DocEntry") AS "IDUtil",
	L."OcrCode2" AS "Centro de custo",
	CC."PrcName" AS "Nome centro de custo",
	C."AcctCode" AS "Conta",
	C."AcctName" AS "Nome da conta"
FROM
	OPDN T0
INNER JOIN PDN1 L ON
	T0."DocEntry" = L."DocEntry"
INNER JOIN OUSR T1 ON
	T0."UserSign" = T1."USERID"
INNER JOIN OPRC CC ON
	CC."PrcCode" = L."OcrCode2"
INNER JOIN OACT C ON
	L."AcctCode" = C."AcctCode"
WHERE
	T0."CANCELED" <> 'C'
UNION 

SELECT
	T0."DocEntry",
	T0."DocNum",
	T0."CardCode",
	T0."CardName" AS "Paceiro de Negocio",
	T0."Serial" AS "Nº NF",
	T0."SeriesStr" AS "Serie",
	T0."DocTotal" AS "Total da Nota",
	CASE
		WHEN T0."DocStatus" = 'C'
		AND T0."CANCELED" = 'Y'
		OR T0."CANCELED" = 'C' THEN 'Cancelado'
		ELSE 'Aberto'
	END AS "Status",
	T0."DocDate" AS "Data de lançamento",
	T0."BPLId",
	T1."USER_CODE",
	T1."U_NAME" AS "Colaborador",
	T0."BPLName" AS "Filial",
	T0."DocDueDate" AS "Data de Vencimento",
	'Dev. Nota Fiscal Saída' AS "Tipo de documento",
	"TaxDate" AS "Data de emissão",
	(
	SELECT
		MAX(T2."Usage")
	FROM
		RIN1
	INNER JOIN OUSG T2 ON
		RIN1."Usage" = T2."ID"
	WHERE
		RIN1."DocEntry" = T0."DocEntry") AS "Utilização",
	(
	SELECT
		MAX(T2."ID")
	FROM
		RIN1
	INNER JOIN OUSG T2 ON
		RIN1."Usage" = T2."ID"
	WHERE
		RIN1."DocEntry" = T0."DocEntry") AS "IDUtil",
	L."OcrCode2" AS "Centro de custo",
	CC."PrcName" AS "Nome centro de custo",
	C."AcctCode" AS "Conta",
	C."AcctName" AS "Nome da conta"
FROM
	ORIN T0
INNER JOIN RIN1 L ON
	T0."DocEntry" = L."DocEntry"
INNER JOIN OUSR T1 ON
	T0."UserSign" = T1."USERID"
INNER JOIN OPRC CC ON
	CC."PrcCode" = L."OcrCode2"
INNER JOIN OACT C ON
	L."AcctCode" = C."AcctCode"
WHERE
	T0."CANCELED" <> 'C'