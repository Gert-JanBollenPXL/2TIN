CREATE OR REPLACE PROCEDURE grootste_dept
IS
    v_dept_id departments.department_id%TYPE;
    v_dept_name departments.department_name%TYPE;
    v_firstname employees.first_name%TYPE;
    v_lastname employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    SELECT d.department_id,d.department_name,e.first_name,e.last_name,e.salary
    INTO v_dept_id,v_dept_name,v_firstname,v_lastname,v_salary
    FROM departments d
    JOIN employees e ON d.department_id = e.department_id
    WHERE d.department_id = (
        SELECT department_id
        FROM (
            SELECT department_id
            FROM employees
            GROUP BY department_id
            ORDER BY COUNT(*) DESC
        )
        WHERE ROWNUM = 1
    )
    AND e.salary = (
        SELECT MAX(salary)
        FROM employees
        WHERE department_id = d.department_id
    );

    DBMS_OUTPUT.PUT_LINE('Grootste afdeling: ' || v_dept_name || ' (ID: ' || v_dept_id || ')');
    DBMS_OUTPUT.PUT_LINE('Hoogste salaris: ' || v_salary || ' (' || v_firstname || ' ' || v_lastname || ')');
END;
/