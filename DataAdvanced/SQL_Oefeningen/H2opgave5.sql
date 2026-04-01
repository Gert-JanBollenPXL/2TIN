DECLARE
    v_last_name      employees.last_name%TYPE;
    v_salary         employees.salary%TYPE;
    v_dept_name      departments.department_name%TYPE;
BEGIN
    SELECT e.last_name,
           e.salary,
           d.department_name
    INTO   v_last_name,
           v_salary,
           v_dept_name
    FROM   employees e
    JOIN   departments d
           ON e.department_id = d.department_id
    WHERE  e.salary = (SELECT MAX(salary) FROM employees);

    DBMS_OUTPUT.PUT_LINE(
        v_last_name || 
        ' werkt in het departement ' || 
        v_dept_name || 
        ' en verdient een maandelijks salaris van ' || 
        v_salary
    );

END;
/