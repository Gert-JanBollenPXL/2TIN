DECLARE
    v_aantal NUMBER;
BEGIN
    minimumlonen('canada', 6250, v_aantal);
    DBMS_OUTPUT.PUT_LINE(v_aantal || ' werknemers kregen een salarisaanpassing.');
END;
/