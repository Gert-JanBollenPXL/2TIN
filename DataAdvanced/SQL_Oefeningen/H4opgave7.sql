CREATE OR REPLACE PROCEDURE country_dept (
    p_country_id IN countries.country_id%TYPE
)
IS
    CURSOR c_dept IS
        SELECT d.department_name
        FROM departments d
        JOIN locations l ON d.location_id = l.location_id
        WHERE UPPER(l.country_id) = UPPER(p_country_id);

    v_dname departments.department_name%TYPE;
    v_aantal INTEGER := 0;
BEGIN
    OPEN c_dept;
    LOOP
        FETCH c_dept INTO v_dname;
        EXIT WHEN c_dept%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dname);
        v_aantal := 1;
    END LOOP;

    IF v_aantal = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'Er zijn geen departementen gevestigd in het land met id ' || p_country_id
        );
    END IF;
END;
/