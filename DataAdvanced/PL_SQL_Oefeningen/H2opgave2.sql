DECLARE
    v_first_name employees.first_name%TYPE;
    v_salary employees.salary%TYPE;
    v_bijdrage NUMBER(10,2);
BEGIN
    SELECT first_name, salary, salary * 0.12
    INTO v_first_name, v_salary, v_bijdrage
    FROM employees
    WHERE employee_id = 155;
    DBMS_OUTPUT.PUT_LINE('Hallo '||v_first_name||CHR(10)||'Je salaris is: '||v_salary||CHR(10)||'Je bijdrage is: '||v_bijdrage);
END;
/
