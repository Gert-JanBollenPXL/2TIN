CREATE OR REPLACE PROCEDURE asterisk_sal(p_emp_id IN employees.employee_id%TYPE)
IS
    v_salary employees.salary%TYPE;
    v_asterisk VARCHAR2(50);
BEGIN
    SELECT salary 
    INTO v_salary 
    FROM employees 
    WHERE employee_id = p_emp_id;
    
-- met loop:
    FOR i in 1 .. TRUNC(v_salary / 1000) LOOP
        v_asterisk := v_asterisk || '*';
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('employee_id: ' || p_emp_id || ', salary: ' || v_salary || ', asterisk: ' || v_asterisk);

-- gewoon in de output met RPAD:
    DBMS_OUTPUT.PUT_LINE('Salaris van werknemer met ID ' || p_emp_id || ': ' || v_salary);
    DBMS_OUTPUT.PUT_LINE('Asterisk weergave: ' || RPAD('*', v_salary / 1000, '*'));
END;
/