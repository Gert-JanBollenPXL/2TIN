CREATE OR REPLACE FUNCTION schrikkeljaarv2(input_date VARCHAR2) RETURN VARCHAR2 AS
    v_schrikkeljaar VARCHAR2(100);
    v_jaar NUMBER := extract(YEAR FROM TO_DATE(input_date, 'DD/MM/RR'));
BEGIN
    IF (v_jaar MOD 4 = 0
        AND (v_jaar MOD 100 != 0 OR v_jaar MOD 400 = 0)) THEN
        v_schrikkeljaar := 'het jaar ' || v_jaar || ' is een schrikkeljaar';
    ELSE
        v_schrikkeljaar := 'het jaar ' || v_jaar || ' is geen schrikkeljaar';
    END IF;
    RETURN v_schrikkeljaar;
END;
/