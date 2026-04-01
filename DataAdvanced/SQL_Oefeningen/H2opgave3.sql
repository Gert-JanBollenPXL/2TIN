DECLARE
    v_first_name  employees.first_name%TYPE;
    v_last_name   employees.last_name%TYPE;
    
    v_salary           employees.salary%TYPE;
    v_commission_pct   employees.commission_pct%TYPE;
    v_yearly_salary    NUMBER;
BEGIN
    v_first_name := 'John';
    v_last_name  := 'Chen';

    SELECT salary,
           NVL(commission_pct,0)
    INTO   v_salary,
           v_commission_pct
    FROM   employees
    WHERE  INITCAP(first_name) = v_first_name
    AND    INITCAP(last_name)  = v_last_name;

    v_yearly_salary := (v_salary * 12) 
                       + (v_salary * 12 * v_commission_pct);

    DBMS_OUTPUT.PUT_LINE(
        v_first_name || ' ' || v_last_name ||
        ' verdient jaarlijks ' || v_yearly_salary
    );

    v_first_name := 'Lisa';
    v_last_name  := 'Ozer';

    SELECT salary,
           NVL(commission_pct,0)
    INTO   v_salary,
           v_commission_pct
    FROM   employees
    WHERE  INITCAP(first_name) = v_first_name
    AND    INITCAP(last_name) = v_last_name;

    v_yearly_salary := (v_salary * 12) 
                       + (v_salary * 12 * v_commission_pct);

    DBMS_OUTPUT.PUT_LINE(
        v_first_name || ' ' || v_last_name ||
        ' verdient jaarlijks ' || v_yearly_salary
    );

END;
/