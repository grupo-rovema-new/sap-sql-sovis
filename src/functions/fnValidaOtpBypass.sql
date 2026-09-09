CREATE OR REPLACE FUNCTION fnValidaOtpBypass(
    regra    NVARCHAR(50),
    otp_info NVARCHAR(16)
)
RETURNS liberado INT
LANGUAGE SQLSCRIPT AS
BEGIN
    DECLARE v_secret NVARCHAR(100);
    DECLARE v_janela BIGINT;
    DECLARE v_regra  NVARCHAR(50);
    DECLARE v_info   NVARCHAR(16);
    DECLARE v_otp0   NVARCHAR(6);
    DECLARE v_otp1   NVARCHAR(6);

    v_secret := 'MINHA_CHAVE_SUPER_SECRETA_2026';

    liberado := 0;

    v_info  := UPPER(TRIM(COALESCE(:otp_info, '')));
    v_regra := UPPER(TRIM(COALESCE(:regra, '')));

    IF v_info <> '' THEN

        v_janela := FLOOR(
            SECONDS_BETWEEN(
                TO_TIMESTAMP('1970-01-01 00:00:00'),
                CURRENT_UTCTIMESTAMP
            ) / 120
        );

        v_otp0 := SUBSTRING(BINTOHEX(HASH_SHA256(TO_BINARY(
            :v_secret || '|' || TO_NVARCHAR(:v_janela)     || '|' || :v_regra
        ))), 1, 6);

        v_otp1 := SUBSTRING(BINTOHEX(HASH_SHA256(TO_BINARY(
            :v_secret || '|' || TO_NVARCHAR(:v_janela - 1) || '|' || :v_regra
        ))), 1, 6);

        IF v_info = v_otp0 OR v_info = v_otp1 THEN
            liberado := 1;
        END IF;

    END IF;
END;
