CREATE OR REPLACE FUNCTION dagen_einde_maand RETURN NUMBER IS
    v_dagen NUMBER;
BEGIN
    v_dagen := LAST_DAY(SYSDATE) - SYSDATE;
    RETURN v_dagen;
END;
/