DECLARE
    v_king_id        employees.employee_id%TYPE;
    v_king_lastname  employees.last_name%TYPE;
    v_king_salary    employees.salary%TYPE;
    v_dept_name      departments.department_name%TYPE;

    v_emp_lastname   employees.last_name%TYPE;
    v_emp_salary     employees.salary%TYPE;

BEGIN
    SELECT e.employee_id,
           e.last_name,
           e.salary,
           d.department_name
    INTO   v_king_id,
           v_king_lastname,
           v_king_salary,
           v_dept_name
    FROM   employees e
    JOIN   departments d
           ON e.department_id = d.department_id
    WHERE  e.salary = (SELECT MAX(salary) FROM employees);

    SELECT last_name,
           salary
    INTO   v_emp_lastname,
           v_emp_salary
    FROM   employees
    WHERE  manager_id = v_king_id
    AND    salary < 6000;

    DBMS_OUTPUT.PUT_LINE(
        v_emp_lastname || 
        ' heeft als baas ' || 
        v_king_lastname || 
        ' en verdient minder dan 6000'
    );

    DBMS_OUTPUT.PUT_LINE(
        v_king_lastname || 
        ' werkt in het departement ' || 
        v_dept_name || 
        ' en verdient een maandelijks salaris van ' || 
        v_king_salary
    );

END;
/