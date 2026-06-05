CREATE OR REPLACE TRIGGER bus_emp
    BEFORE UPDATE OF salary on EMPLOYEES

BEGIN
    IF (:NEW.salary > :OLD.salary * 1.05) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Je mag het salaris niet met meer dan 5% verhogen.');
    ElSIF (:NEW.salary < :OLD.salary) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Je mag het salaris niet verlagen.');
    END IF;
END;
/