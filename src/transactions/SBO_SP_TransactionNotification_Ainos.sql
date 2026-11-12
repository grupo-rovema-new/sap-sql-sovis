CREATE OR REPLACE PROCEDURE SBO_SP_TransactionNotification_Ainos
(
    IN object_type NVARCHAR(30),                 -- SBO Object Type
    IN transaction_type NCHAR(1),                -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    IN num_of_cols_in_key INT,
    IN list_of_key_cols_tab_del NVARCHAR(255),
    IN list_of_cols_val_tab_del NVARCHAR(255),
    INOUT error INT,
    INOUT error_message NVARCHAR(200)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
    error INT; -- Result, 0 para sem erro
    error1 INT;
    error2 INT;
    error3 INT;
    error4 INT;
    erroAdiantamento INT;

    XITEM NVARCHAR(255);
    XCOUNT INT;

    error_message NVARCHAR(255);

    currDbNameForTaxOne NVARCHAR(128);
    companyDbIntBank NVARCHAR(128);

    -- Variáveis da trava de LC manual
    qtdLinhas INT;
    qtdForaGrupo INT;
    qtdGrupo1 INT;
    qtdGrupo5 INT;
    usuarioNaLista INT;
    lcManual INT;
    contaErro NVARCHAR(255);

BEGIN

    error := 0;
    error_message := N'Ok';

    -------------------------------------------------------------------------
    -- TRAVA: LANÇAMENTO CONTÁBIL MANUAL
    --
    -- Objetivo:
    -- Bloquear apenas LC manual para usuários específicos.
    --
    -- Segurança:
    -- object_type = '30' identifica lançamento contábil.
    -- OJDT."TransType" = 30 garante que a ORIGEM também é LC manual.
    --
    -- Portanto, lançamentos originados por nota fiscal, contas a receber,
    -- pagamento, baixa, etc. não devem ser afetados por esta regra.
    -------------------------------------------------------------------------

    IF :object_type = '30' AND :transaction_type IN ('A', 'U') THEN

        qtdLinhas := 0;
        qtdForaGrupo := 0;
        qtdGrupo1 := 0;
        qtdGrupo5 := 0;
        usuarioNaLista := 0;
        lcManual := 0;
        contaErro := '';

        -- Garante que a origem do lançamento é LC manual
        SELECT COUNT(*)
          INTO lcManual
          FROM OJDT T0
         WHERE T0."TransId" = TO_INTEGER(:list_of_cols_val_tab_del)
           AND T0."TransType" = 30;

        -- Só continua se for realmente LC manual
        IF :lcManual > 0 THEN

            -- Verifica se o autor do lançamento está na lista de usuários controlados.
            -- Aqui estou assumindo que 252 e 235 são OUSR."INTERNAL_K",
            -- gravados em OJDT."UserSign".
            SELECT COUNT(*)
              INTO usuarioNaLista
              FROM OJDT T0
             WHERE T0."TransId" = TO_INTEGER(:list_of_cols_val_tab_del)
               AND T0."UserSign" IN (
                    252,
                    235
               );

            -- Só aplica a trava para os usuários da lista
            IF :usuarioNaLista > 0 THEN

                -- Força o lançamento a ter exatamente 2 linhas
                SELECT COUNT(*)
                  INTO qtdLinhas
                  FROM JDT1 T0
                 WHERE T0."TransId" = TO_INTEGER(:list_of_cols_val_tab_del);

                IF :qtdLinhas <> 2 THEN

                    error := 1;
                    error_message := 'LC manual permitido somente com exatamente 2 linhas para este usuário.';

                ELSE

                    -- Verifica se existe alguma conta fora dos grupos permitidos
                    SELECT COUNT(*)
                      INTO qtdForaGrupo
                      FROM JDT1 T0
                      JOIN OACT T1 ON T1."AcctCode" = T0."Account"
                     WHERE T0."TransId" = TO_INTEGER(:list_of_cols_val_tab_del)
                       AND IFNULL(T1."GroupMask", 0) NOT IN (1, 5);

                    IF :qtdForaGrupo > 0 THEN

                        SELECT 
                            T1."FormatCode" || ' - ' || T1."AcctName"
                          INTO contaErro
                          FROM JDT1 T0
                          JOIN OACT T1 ON T1."AcctCode" = T0."Account"
                         WHERE T0."TransId" = TO_INTEGER(:list_of_cols_val_tab_del)
                           AND IFNULL(T1."GroupMask", 0) NOT IN (1, 5)
                         LIMIT 1;

                        error := 1;
                        error_message := 'LC manual bloqueado. Conta fora dos grupos permitidos: ' || contaErro;

                    ELSE

                        -- Garante que tenha pelo menos uma linha começando com 1.1.1.0
					    SELECT COUNT(*)
					      INTO qtdGrupo1
					      FROM JDT1 T0
					      JOIN OACT T1 ON T1."AcctCode" = T0."Account"
					     WHERE T0."TransId" = TO_INTEGER(:list_of_cols_val_tab_del)
					       AND T1."FormatCode" LIKE '1.1.1.0%';

						-- Garante que tenha pelo menos uma linha começando com 5.1.1
					    SELECT COUNT(*)
					      INTO qtdGrupo5
					      FROM JDT1 T0
					      JOIN OACT T1 ON T1."AcctCode" = T0."Account"
					     WHERE T0."TransId" = TO_INTEGER(:list_of_cols_val_tab_del)
					       AND T1."FormatCode" LIKE '5.1.1%';

                        IF :qtdGrupo1 = 0 OR :qtdGrupo5 = 0 THEN

                            error := 1;
                            error_message := 'LC manual permitido somente entre contas dos grupos 1 e 5 para este usuário.';

                        END IF;

                    END IF;

                END IF;

            END IF;

        END IF;

    END IF;

END;