DECLARE
    CURSOR c_emp IS
        SELECT department_id, last_name, salary, manager_id
        FROM employees
        ORDER BY department_id, last_name;

    rec_emp c_emp%ROWTYPE;
    v_dept employees.department_id%TYPE := 0;

BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO rec_emp;
        EXIT WHEN c_emp%NOTFOUND;

        IF v_dept <> rec_emp.department_id AND rec_emp.department_id IS NOT NULL THEN
            v_dept := rec_emp.department_id;
            DBMS_OUTPUT.PUT_LINE('Departement: ' || v_dept);
        ELSIF rec_emp.department_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Werknemers zonder departement:');
        END IF;

        IF rec_emp.salary < 6000 AND rec_emp.manager_id IN (101,124) THEN
            DBMS_OUTPUT.PUT_LINE(rec_emp.last_name || ' komt in aanmerking voor loonsverhoging');
        ELSE
            DBMS_OUTPUT.PUT_LINE(rec_emp.last_name || ' komt niet in aanmerking voor loonsverhoging');
        END IF;

    END LOOP;
    CLOSE c_emp;
END;
/