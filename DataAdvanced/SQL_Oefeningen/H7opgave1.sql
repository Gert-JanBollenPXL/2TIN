CREATE OR REPLACE TRIGGER bur_emp
    BEFORE UPDATE OF max_salary OR min_salary
    ON jobs
    FOR EACH ROW

BEGIN
    IF USER = 'student' OR USER = 'bezoeker' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Je hebt geen rechten om deze actie uit te voeren.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ben je zeker dat je het minimum en/of maximum salaris van één of meerdere jobs wil aanpassen?
         Indien niet voer dan onmiddellijk een ROLLBACK uit!');
    END IF;
END;
/