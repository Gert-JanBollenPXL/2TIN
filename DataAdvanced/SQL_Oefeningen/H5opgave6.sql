CREATE OR REPLACE FUNCTION volgende_vergadering RETURN DATE AS
    v_vergadering     DATE;

BEGIN
    v_vergadering := NEXT_DAY(LAST_DAY(SYSDATE), 'MONDAY');

    IF TO_CHAR(v_vergadering, 'DD-MON') IN ('01-JAN', '01-MAY') THEN
        v_vergadering := v_vergadering + 1;
    END IF;

    RETURN v_vergadering;
END;
/