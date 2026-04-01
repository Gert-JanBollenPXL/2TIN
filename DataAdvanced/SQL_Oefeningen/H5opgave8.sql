CREATE OR REPLACE FUNCTION jubileumdate (
    input_first_name  employees.first_name%TYPE,
    input_last_name employees.last_name%TYPE
) RETURN VARCHAR2
AS
    v_jubileum_date DATE;
BEGIN
    SELECT hire_date + INTERVAL '30' YEAR
    INTO v_jubileum_date
    FROM employees
    WHERE UPPER(last_name) = UPPER(input_last_name)
      AND UPPER(first_name) = UPPER(input_first_name);

    IF v_jubileum_date < SYSDATE THEN
        RETURN 'werd reeds gevierd op ' || TO_CHAR(v_jubileum_date, 'DD-MON-YY');
    END IF;

    IF TO_CHAR(v_jubileum_date, 'DAY') <> 'FRIDAY' THEN
        v_jubileum_date := NEXT_DAY(v_jubileum_date, 'FRIDAY');
    END IF;

    RETURN TO_CHAR(v_jubileum_date, 'DD-MON-YY');
END;
/