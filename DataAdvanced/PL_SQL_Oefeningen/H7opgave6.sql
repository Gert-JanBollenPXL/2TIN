CREATE OR REPLACE TRIGGER buir_emp
    BEFORE UPDATE OR INSERT ON employees
    FOR EACH ROW

BEGIN
    :NEW.job_id := UPPER(:NEW.job_id);
    :NEW.first_name := INITCAP(:NEW.first_name);
    :NEW.last_name := INITCAP(:NEW.last_name);

    IF (:NEW.hire_date < SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20001, 'De aanstellingsdatum mag niet in het verleden liggen.');
    END IF;

    IF (:NEW.job_id LIKE '%MAN' OR :NEW.job_id LIKE '%MGR') AND :OLD.job_id NOT IN ('AD_PRES', 'AD_VP') THEN
        :NEW.salary := :NEW.salary * 1.05;
    END IF;
END
/