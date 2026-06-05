CREATE OR REPLACE PROCEDURE loonsverhoging (
    p_dept_id     IN departments.department_id%TYPE,
    p_percentage  IN NUMBER
)
IS
    v_dept_name departments.department_name%TYPE;

    CURSOR c_employees IS
        SELECT employee_id, last_name, salary
        FROM employees
        WHERE department_id = p_dept_id;
    rec c_employees%ROWTYPE;

BEGIN
    -- 1. Departementsnaam ophalen
    SELECT department_name
    INTO v_dept_name
    FROM departments
    WHERE department_id = p_dept_id;

    DBMS_OUTPUT.PUT_LINE('Het gekozen departement is: ' || v_dept_name);

    -- 2. Huidige situatie
    OPEN c_employees;
    LOOP
        FETCH c_employees INTO rec;
        EXIT WHEN c_employees%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            rec.employee_id || ' ' || rec.last_name || ': ' || rec.salary
        );
    END LOOP;
    CLOSE c_employees;

    -- 3. Salarisverhoging
    UPDATE employees
    SET salary = salary + (salary * p_percentage / 100)
    WHERE department_id = p_dept_id;

    DBMS_OUTPUT.NEW_LINE;

    -- 4. Aantal updates
    DBMS_OUTPUT.PUT_LINE('Aantal salarisverhogingen : ' || SQL%ROWCOUNT);

    -- 5. Nieuwe situatie
    DBMS_OUTPUT.PUT_LINE('SITUATIE NA WIJZIGING.');

    OPEN c_employees;
    LOOP
        FETCH c_employees INTO rec;
        EXIT WHEN c_employees%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            rec.employee_id || ' ' || rec.last_name || ': ' || rec.salary
        );
    END LOOP;
    CLOSE c_employees;
END;
/