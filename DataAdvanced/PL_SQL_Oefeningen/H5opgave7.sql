CREATE OR REPLACE FUNCTION next_employee_id RETURN 
employees.employee_id%TYPE AS
    v_id employees.employee_id%TYPE;

BEGIN
    SELECT MAX(employee_id) 
    INTO v_id 
    FROM employees;
    
    RETURN v_id + 1;
END;    
/