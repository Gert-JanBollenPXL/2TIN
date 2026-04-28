CREATE OR REPLACE PROCEDURE info_geboorte (
    p_dag INTEGER,
    p_maand INTEGER,
    p_jaar INTEGER
)

AS
    v_geboortedatum DATE;
    v_volgende_verjaardag DATE;
    v_leeftijd INTEGER;

BEGIN
    v_geboortedatum := TO_DATE(p_dag || '/' || p_maand || '/' || p_jaar, 'DD/MM/YYYY');
    v_volgende_verjaardag := ADD_MONTHS(v_geboortedatum, 12);
    v_leeftijd := FLOOR(MONTHS_BETWEEN(SYSDATE, v_geboortedatum) / 12);

    DBMS_OUTPUT.PUT_LINE('Je bent geboren op een ' || TO_CHAR(v_geboortedatum, 'Day'));
    DBMS_OUTPUT.PUT_LINE('Je volgende verjaardag is op ' || TRIM(TO_CHAR(v_volgende_verjaardag, 'Day')) || ', ' 
    || TO_CHAR(v_volgende_verjaardag, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Je bent ' || v_leeftijd || ' jaar oud');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ongeldige datum ingevoerd. Probeer het opnieuw.');

END;
/