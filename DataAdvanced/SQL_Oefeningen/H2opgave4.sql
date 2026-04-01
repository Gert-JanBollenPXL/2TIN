DECLARE
    v_deptname      departments.department_name%TYPE;
    v_count         NUMBER;
BEGIN
    SELECT department_name
    INTO   v_deptname
    FROM   departments
    WHERE  department_id = &departementsnummer;

    SELECT COUNT(*)
    INTO   v_count
    FROM   employees
    WHERE  department_id = &departementsnummer;

    DBMS_OUTPUT.PUT_LINE(
        v_count || ' werknemers werken in departement ' || v_deptname
    );
END;
/