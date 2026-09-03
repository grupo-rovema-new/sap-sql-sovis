CREATE OR REPLACE FUNCTION "Tolerancia_Arredondamento_Desonerado"(quantidade DECIMAL(19,6), linhas INTEGER)
RETURNS tolerancia DECIMAL(19,6) LANGUAGE SQLSCRIPT AS

-- Folga que as travas de valor precisam dar para o residuo de arredondamento do calculo de
-- desonerado, que NAO e desconto de verdade e nao da para eliminar.
--
-- De onde vem cada parcela (ver PrecoUnitarioComDesoneracao.calculaPreco no sap-rovema):
--
--   0,05                     piso, para documento pequeno onde o residuo e desprezivel;
--   0,0001 x quantidade      o calculaPreco faz DUAS divisoes truncadas em 4 casas (desconto e
--                            depois aliquota). Cada uma erra ate 0,00005 no preco unitario, e
--                            esse erro e multiplicado pela quantidade;
--   0,02 x linhas            os arredondamentos de 2 casas (total da linha, imposto, esperado),
--                            um conjunto por linha do documento.
--
-- O eixo e QUANTIDADE, nao valor: duas notas de mesmo valor, uma de 560 sacas a R$ 58 e outra de
-- 20.000 kg a R$ 1,60, tem residuos muito diferentes. Escalar por valor deixa produto barato
-- vendido a granel apertado demais e volta a barrar documento correto.
--
-- Caso real (DocNum 65419, 560 unidades em 1 linha): residuo observado 0,0708; esta formula da
-- 0,05 + 0,056 + 0,02 = 0,126.
--
-- Usada pelas travas de desconto (SBO_SP_TransactionNotification_Rovema) e de valor negociado
-- (SBO_SP_VALIDACAO_VENDA). As duas precisam da MESMA folga: e o mesmo residuo batendo em dois
-- lugares, e tolerancia diferente entre elas cria o vao onde o 65419 caiu (0,07 passava numa e
-- barrava na outra).

BEGIN
    tolerancia := 0.05
                + 0.0001 * COALESCE(:quantidade, 0)
                + 0.02   * COALESCE(:linhas, 0);
END;
