CREATE OR REPLACE PROCEDURE asterisk_sal (
    p_emp_id    IN  employees.employee_id%TYPE,
    p_asterisk  OUT VARCHAR2
)
IS
    v_salary employees.salary%TYPE;
BEGIN
    SELECT salary 
    INTO v_salary 
    FROM employees 
    WHERE employee_id = p_emp_id;

    p_asterisk := '';

    FOR i IN 1 .. TRUNC(v_salary / 1000) LOOP
        p_asterisk := p_asterisk || '*';
    END LOOP;
END;
/