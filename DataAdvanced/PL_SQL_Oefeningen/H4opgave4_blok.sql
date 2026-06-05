DECLARE
    v_result VARCHAR2(50);
BEGIN
    asterisk_sal(100, v_result);

    DBMS_OUTPUT.PUT_LINE('Asterisk weergave voor werknemer 100: ' || v_result);
END;
/