DECLARE
    v_emp_id    employees.employee_id%TYPE := &emp_id;
    v_emp_firstname  employees.first_name%TYPE;
    v_emp_lastname   employees.last_name%TYPE;
    v_emp_salary     employees.salary%TYPE;
    v_emp_tax      employees.salary%TYPE;

BEGIN
    SELECT first_name,
           last_name,
           salary * 12
    INTO   v_emp_firstname,
           v_emp_lastname,
           v_emp_salary
    FROM   employees
    WHERE  employee_id = v_emp_id;

    IF v_emp_salary < 30000 THEN
        v_emp_tax := v_emp_salary * 0.25;
    ELSIF v_emp_salary < 55000 THEN
        v_emp_tax := (30000 * 0.25) + ((v_emp_salary - 30000) * 0.50);
    ELSE
        v_emp_tax := (30000 * 0.25) + (25000 * 0.50) + ((v_emp_salary - 55000) * 0.60);
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        v_emp_firstname || ' ' || v_emp_lastname ||
        ' moet ' || TO_CHAR(v_emp_tax, 'fm999,999.99') || ' belasting betalen'
    );
END;
/