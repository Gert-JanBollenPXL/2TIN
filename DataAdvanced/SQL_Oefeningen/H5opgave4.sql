CREATE OR REPLACE FUNCTION aantal_jaren(ingevoerde_datum IN VARCHAR2) RETURN NUMBER AS
    v_aantal_jaren DATE;

BEGIN
    v_aantal_jaren := TO_DATE(ingevoerde_datum, 'DD/MM/RR');
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, v_aantal_jaren) / 12);
END;
/