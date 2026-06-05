CREATE OR REPLACE PROCEDURE add_job (
    p_job_id IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE,
    p_min_salary IN jobs.min_salary%TYPE,
    p_max_salary IN jobs.max_salary%TYPE
)

AS
    v_result VARCHAR2(100);

BEGIN
    INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
    VALUES (UPPER(p_job_id), p_job_title, p_min_salary, p_max_salary);

    v_result := 'Job ' || p_job_title || ' added successfully.';
    DBMS_OUTPUT.PUT_LINE(v_result);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_result := 'Dit id is reeds in gebruik';
        DBMS_OUTPUT.PUT_LINE(v_result);

END;
/