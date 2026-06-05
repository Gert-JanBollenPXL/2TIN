CREATE OR REPLACE PROCEDURE info_geboorte_toekomst (
    p_dag INTEGER,
    p_maand INTEGER,
    p_jaar INTEGER
)

AS
    v_geboortedatum DATE;
    v_volgende_verjaardag DATE;
    v_leeftijd INTEGER;

        e_foute_dag EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_foute_dag, -1847);
    e_foute_maand EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_foute_maand, -1843);
    e_fout_jaar EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_fout_jaar, -1841);
    e_invalid_date EXCEPTION;

BEGIN
    v_geboortedatum := TO_DATE(p_dag || '/' || p_maand || '/' || p_jaar, 'DD/MM/YYYY');
    v_volgende_verjaardag := ADD_MONTHS(v_geboortedatum, 12);
    v_leeftijd := FLOOR(MONTHS_BETWEEN(SYSDATE, v_geboortedatum) / 12);

    IF v_geboortedatum > SYSDATE THEN
        RAISE e_invalid_date;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Je bent geboren op een ' || TO_CHAR(v_geboortedatum, 'Day'));
    DBMS_OUTPUT.PUT_LINE('Je volgende verjaardag is op ' || TRIM(TO_CHAR(v_volgende_verjaardag, 'Day')) || ', ' 
    || TO_CHAR(v_volgende_verjaardag, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Je bent ' || v_leeftijd || ' jaar oud');

EXCEPTION
    WHEN e_foute_dag THEN
        DBMS_OUTPUT.PUT_LINE('Ongeldige dag ingevoerd. Probeer het opnieuw.');
    WHEN e_foute_maand THEN
        DBMS_OUTPUT.PUT_LINE('Ongeldige maand ingevoerd. Probeer het opnieuw.');
    WHEN e_fout_jaar THEN
        DBMS_OUTPUT.PUT_LINE('Ongeldig jaar ingevoerd. Probeer het opnieuw.');
    WHEN e_invalid_date THEN
        DBMS_OUTPUT.PUT_LINE('De geboortedatum mag niet in de toekomst liggen. Probeer het opnieuw.');
END;
/