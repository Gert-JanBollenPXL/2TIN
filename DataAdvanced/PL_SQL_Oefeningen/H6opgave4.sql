CREATE OR REPLACE PROCEDURE emp_nieuwe_job (
    p_naam IN employees.last_name%TYPE,
    p_nieuwe_job_id IN employees.job_id%TYPE
)

AS
    v_employee_id employees.employee_id%TYPE;
    v_hire_date employees.hire_date%TYPE;
    v_job_id employees.job_id%TYPE;
    v_department_id employees.department_id%TYPE;
    v_start_date job_history.start_date%TYPE;
    v_end_date job_history.end_date%TYPE;

    e_fout_job_id EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_fout_job_id, -2291);

BEGIN
    SELECT employee_id, hire_date, job_id, department_id
    INTO v_employee_id, v_hire_date, v_job_id, v_department_id
    FROM employees
    WHERE UPPER(last_name) = UPPER(p_naam);

    SELECT MAX(end_date) + 1
    INTO v_start_date
    FROM job_history
    WHERE employee_id = v_employee_id;

    IF v_start_date IS NULL THEN
        v_start_date := v_hire_date;
    END IF;

    v_end_date := to_date(to_char(SYSDATE, 'dd-mm-yyyy'), 'dd-mm-yyyy') - 1;

    INSERT INTO job_history
    VALUES (v_employee_id, v_start_date, v_end_date, v_job_id, v_department_id);

    UPDATE employees
    SET job_id = p_nieuwe_job_id
    WHERE employee_id = v_employee_id;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Werknemer bestaat niet.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Meerdere werknemers met deze naam.');
    WHEN e_fout_job_id THEN
        DBMS_OUTPUT.PUT_LINE('Job_id bestaat niet.');

END;
/