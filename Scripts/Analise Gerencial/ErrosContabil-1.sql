/** TODO
 * [] 1 - Identificar os CSTS que sao de venda, e nao esta na tela correta
 *  2 - Identificar as notas baseado no CST que nao tem conta de contra partida esperada
 *  3 - Verificar as entregas e que nao tem lancamento contabil relacionado
 *  4 - verificar notas ativas no taxone que estao canceladas no SAP - DocEntry OINV de exemplo 7363
 *  5 - Verificar conta de estoque? Talvez....
 *  6 - faser trava no desvio do saldo do estoque!?
 */

SELECT 
	doc."DocEntry",
	doc."DocNum",
	doc."Model",
	doc."Serial",
	doc."ObjType"
FROM
	"OINV" as doc
	INNER JOIN "Process" sefaz ON (sefaz."DocType" = doc."ObjType" AND doc."DocEntry" = sefaz."DocEntry")
WHERE
	doc."BPLId" IN(2,4,11,16,17,18	 4 33 2)
	AND doc."SeqCode" <> 27 
	

SELECT * FROM "Process" p WHERE "DocEntry" = 7363

SELECT * FROM "ProcessStatus"


	
WHERE

	T0."CANCELED" = 'N'
	AND (T1."Usage"  = 9)
	AND T0."DocDate" >= '2023-01-01'
	AND T0."DocDate" <= '2024-01-31'
	
GROUP BY
	T1."Usage"
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
