CREATE OR REPLACE PROCEDURE minimumlonen (
    p_landnaam     IN  countries.country_name%TYPE,
    p_min_salaris  IN  employees.salary%TYPE,
    p_aantal       OUT NUMBER
)
IS
BEGIN
    UPDATE employees e
    SET salary = p_min_salaris
    WHERE e.salary < p_min_salaris
      AND e.department_id IN (
          SELECT d.department_id
          FROM departments d
          JOIN locations l ON d.location_id = l.location_id
          JOIN countries c ON l.country_id = c.country_id
          WHERE UPPER(c.country_name) = UPPER(p_landnaam)
      );

    -- aantal gewijzigde rijen teruggeven
    p_aantal := SQL%ROWCOUNT;
END;
/