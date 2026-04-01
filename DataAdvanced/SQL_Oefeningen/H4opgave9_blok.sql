DECLARE
    v_aantal NUMBER(2);
    v_country_id countries.country_id%TYPE := 'US';

BEGIN
    werknemers_dept(v_country_id, v_aantal);
    DBMS_OUTPUT.PUT_LINE('Totaal aantal werknemers in ' || v_country_id || ': ' || v_aantal);
END;
/