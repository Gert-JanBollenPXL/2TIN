DECLARE
    CURSOR c_country_cursor IS
        SELECT country_name
        FROM countries;
    v_country_name  countries.country_name%TYPE;
    v_counter       NUMBER := 0;

BEGIN
    OPEN c_country_cursor;
    LOOP
        FETCH c_country_cursor INTO v_country_name;
        EXIT WHEN c_country_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_country_name);
        v_counter := v_counter + 1;
    END LOOP;
    CLOSE c_country_cursor;

-- ipv  v_counter te gebruiken, kunnen we ook: c_country_cursor%ROWCOUNT gebruiken
    DBMS_OUTPUT.PUT_LINE('Totaal aantal landen: ' || v_counter);

    CLOSE c_country_cursor;
END;
/