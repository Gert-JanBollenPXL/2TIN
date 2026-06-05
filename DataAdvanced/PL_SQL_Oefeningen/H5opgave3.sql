CREATE OR REPLACE FUNCTION aantal_dienstjaren(emp_id employees.employee_id%TYPE) RETURN NUMBER IS
    v_aantal_dienstjaren NUMBER;

    v_emp_firstname  employees.first_name%TYPE;
    v_emp_lastname   employees.last_name%TYPE;
    v_emp_hire_date  employees.hire_date%TYPE;
BEGIN
    SELECT first_name,
           last_name,
           hire_date
    INTO   v_emp_firstname,
            v_emp_lastname,
            v_emp_hire_date
    FROM   employees
    WHERE  employee_id = emp_id;
    v_aantal_dienstjaren := TRUNC(MONTHS_BETWEEN(SYSDATE, v_emp_hire_date) / 12);
    RETURN v_aantal_dienstjaren;
END;
/