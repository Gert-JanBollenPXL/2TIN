CREATE OR REPLACE TRIGGER buir_emp
    BEFORE UPDATE OR INSERT ON employees
    FOR EACH ROW
    WHEN (OLD.job_id != 'AD_PRES' OR OLD.job_id != 'AD_VP')

BEGIN
    job_id := UPPER(job_id);
    first_name := INITCAP(first_name);
    last_name := INITCAP(last_name);

    IF (:NEW.hire_date < SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'De aanstellingsdatum mag niet in het verleden liggen.');
    END IF;

    IF (:NEW.job_id CONTAINS 'MAN' OR :NEW.job_id CONTAINS 'MGR') THEN
        employee.salary := salary * 1.05;
    END IF;
END
/