CREATE OR REPLACE TRIGGER bids_emp
    BEFORE INSERT OR DELETE ON employees


DECLARE
    v_manager_id   employees.manager_id%TYPE;
    v_first_name   employees.first_name%TYPE;
    v_last_name    employees.last_name%TYPE;
BEGIN
    IF (:NEW.manager_id IS NULL) THEN
        SELECT manager_id
        INTO v_manager_id
        FROM departments
        WHERE department_id = :NEW.department_id;

        :NEW.manager_id := v_manager_id;

        SELECT first_name, last_name
        INTO v_first_name, v_last_name
        FROM employees
        WHERE employee_id = v_manager_id;

        DBMS_OUTPUT.PUT_LINE('de chef wordt ' || v_first_name || ' ' || v_last_name);
    END IF;

    IF :NEW.hire_date IS NULL THEN
        :NEW.hire_date := NEXT_DAY(SYSDATE, 'MONDAY');
    END IF;

    IF :NEW.salary IS NULL THEN
        :NEW.salary := 1000;

        DBMS_OUTPUT.PUT_LINE('het salaris van employee '  || :NEW.first_name || ' ' || :NEW.last_name  || ' wordt 1000');
    END IF;

    IF DELETING THEN
        DBMS_OUTPUT.PUT_LINE('dit is per maand een besparing van ' || :OLD.salary || ' euro');
    END IF;

END;
/