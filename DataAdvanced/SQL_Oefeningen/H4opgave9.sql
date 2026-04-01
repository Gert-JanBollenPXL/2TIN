CREATE OR REPLACE PROCEDURE werknemers_dept (
    p_country_id IN countries.country_id%TYPE,
    p_aantalWN OUT NUMBER
)
IS
    v_aantal NUMBER(3);
    v_country_name countries.country_name%TYPE;
    v_aantalWN NUMBER(3);

    CURSOR cur_dept IS
        SELECT location_id, city
        FROM locations
        WHERE country_id = p_country_id;

    CURSOR cur_emp(p_locid NUMBER) IS
        SELECT department_name, COUNT(*) aantal
        FROM departments d
        JOIN employees e ON d.department_id = e.department_id
        WHERE location_id = p_locid
        GROUP BY department_name;

    rec_dept cur_dept%ROWTYPE;
    rec_emp cur_emp%ROWTYPE;

    v_aantaldept INTEGER := 0;
BEGIN

    p_aantalWN := 0;

    SELECT country_name
    INTO v_country_name
    FROM countries
    WHERE country_id = p_country_id;

    OPEN cur_dept;
    LOOP
        FETCH cur_dept INTO rec_dept;
        EXIT WHEN cur_dept%NOTFOUND;
        v_aantaldept := 1;
        DBMS_OUTPUT.PUT_LINE('==> ' || v_country_name || ' - ' || rec_dept.location_id || ' ' || rec_dept.city);

        OPEN cur_emp(rec_dept.location_id);
        LOOP
            FETCH cur_emp INTO rec_emp;
            EXIT WHEN cur_emp%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(rec_emp.department_name || ': ' || rec_emp.aantal || ' werknemers');
            p_aantalWN := p_aantalWN + rec_emp.aantal;
        END LOOP;
        CLOSE cur_emp;
    END LOOP;
    CLOSE cur_dept;
    IF v_aantaldept = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Er zijn geen locaties in dit land');
    END IF;    
END;
/