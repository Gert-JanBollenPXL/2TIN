CREATE OR REPLACE TRIGGER bur_emp
    BEFORE UPDATE OF salary on EMPLOYEES
    FOR EACH ROW
    WHEN (OLD.hire_date < to_date('01-01-1995', 'dd-mm-yyyy'))
BEGIN
    IF (:NEW.salary > :OLD.salary * 1.05) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Je mag het salaris niet met meer dan 5% verhogen.');
    ElSIF (:NEW.salary < :OLD.salary) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Je mag het salaris niet verlagen.');
    END IF;
END;
/