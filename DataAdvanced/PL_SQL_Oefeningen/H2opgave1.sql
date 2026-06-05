DECLARE
    v_department_id departments.department_id%TYPE;
BEGIN
    SELECT MAX(department_id)
    INTO v_department_id
    FROM departments;
    DBMS_OUTPUT.PUT_LINE('Het hoogste departementsnummer is: '||v_department_id);
END;
/
