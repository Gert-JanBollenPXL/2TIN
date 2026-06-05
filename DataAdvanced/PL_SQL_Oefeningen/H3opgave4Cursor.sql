DECLARE
    CURSOR c_emp IS
        SELECT department_id, last_name, salary, manager_id
        FROM employees
        ORDER BY department_id, last_name;

    v_deptid employees.department_id%TYPE := 0;
    v_dept employees.department_id%TYPE;
    v_last_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
    v_manager_id employees.manager_id%TYPE;

BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_dept, V_last_name, v_salary, v_manager_id;
        EXIT WHEN c_emp%NOTFOUND;

        IF v_deptid <> v_dept AND v_dept IS NOT NULL THEN
            v_deptid := v_dept;
            DBMS_OUTPUT.PUT_LINE('Departement: ' || v_dept);
        ELSIF v_dept IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Werknemers zonder departement:');
        END IF;

        IF v_salary < 6000 AND v_manager_id IN (101,124) THEN
            DBMS_OUTPUT.PUT_LINE( v_last_name || ' komt in aanmerking voor loonsverhoging');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_last_name || ' komt niet in aanmerking voor loonsverhoging');
        END IF;

    END LOOP;
    CLOSE c_emp;
END;
/