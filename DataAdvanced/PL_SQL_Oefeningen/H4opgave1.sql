CREATE OR REPLACE PROCEDURE  toon_laatste_emp
IS
    v_emp_id employees.employee_id%TYPE;
    v_firstname employees.first_name%TYPE;
    v_lastname employees.last_name%TYPE;
    v_hire_date employees.hire_date%TYPE;
BEGIN
    SELECT employee_id, first_name, last_name, hire_date
    INTO v_emp_id, v_firstname, v_lastname, v_hire_date
    FROM employees
    WHERE hire_date = (SELECT MAX(hire_date) FROM employees);

    DBMS_OUTPUT.PUT_LINE('Laatste werknemer: ' || v_firstname || ' ' || v_lastname || ' (ID: ' || v_emp_id || ')');
END;
/