# Oplossingen voorbeeld examenvragen PL/SQL

## Opgave 1

Creëer de functie (aantal_wn) die als input een stad heeft en vervolgens het aantal werknemers die in die stad werken, teruggeeft.

Voorbeeld:

```sql
SELECT aantal_wn('toronto') FROM DUAL; -> 2
```
#### Oplossing

```sql
CREATE OR REPLACE FUNCTION aantal_wn (
    p_stad VARCHAR2
)
RETURN NUMBER
IS
    v_aantal NUMBER(3);
BEGIN
    SELECT COUNT(*)
    INTO v_aantal
    FROM employees e JOIN departments d
    ON e.department_id = d.department_id
    JOIN locations l
    ON d.location_id = l.location_id
    WHERE UPPER(l.city) = UPPER(p_stad);

    RETURN v_aantal;
END;
/
```

---

## Opgave 2

De procedure “volledige_naam” met als input de personeelsnummer (employee_id) geeft de voornaam gekoppeld aan de familienaam terug aan het calling program via een parameter.

Vervolledig onderstaande code:

```sql
CREATE OR REPLACE PROCEDURE volledige_naam (
...................................)
IS
BEGIN
    SELECT first_name || ' '|| last_name
    INTO p_naam
    FROM employees
    WHERE employee_id = p_id;
END;
/
```

#### IN TE VULLEN CODE

```sql
p_id employees.employee_id%TYPE,
p_naam OUT VARCHAR2
```

---

## Opgave 3

De functie “belasting(p_jaarsal)” berekent de belasting per jaar:

(opmerking: met het commissieloon hoeft geen rekening gehouden te worden)

```sql
CREATE OR REPLACE FUNCTION belasting (p_jaarsal NUMBER)
RETURN NUMBER
IS
    v_belasting NUMBER;
BEGIN
    IF p_jaarsal <= 30000 THEN
        v_belasting := ROUND(p_jaarsal * 0.25);
    ELSIF p_jaarsal <= 55000 THEN
        v_belasting := ROUND(30000 * 0.25 + (p_jaarsal-30000) * 0.5);
    ELSE
        v_belasting := ROUND(30000 * 0.25 + 25000 * 0.5 + (p_jaarsal-55000) * 0.6);
    END IF;
    RETURN v_belasting;
END;
/
```

Schrijf een anoniem blok code die van elke werknemer de jaarlijkse belasting weergeeft. De data wordt in alfabetische volgorde op familienaam weergegeven:

```text
Ellen Abel betaalt 66200 belasting per jaar.
Sundar Ande betaalt 33080 belasting per jaar.
Mozef Atkinson betaalt 9300 belasting per jaar.
David Austin betaalt 21560 belasting per jaar.
Hermann Baer betaalt 59000 belasting per jaar.
…
```
#### Oplossing

```sql
DECLARE
    CURSOR cur_emp IS
        SELECT first_name, last_name, salary * 12 jaarsal
        FROM employees
        ORDER BY last_name;
    rec_emp cur_emp%ROWTYPE;
    v_belasting NUMBER(8);
BEGIN
    OPEN cur_emp;
    LOOP
        FETCH cur_emp INTO rec_emp;
        EXIT WHEN cur_emp%NOTFOUND;
        v_belasting := belasting(rec_emp.jaarsal);
        DBMS_OUTPUT.PUT_LINE(rec_emp.first_name || ' ' || rec_emp.last_name || '
            betaalt ' || v_belasting || ' belasting per jaar.');
    END LOOP;
    CLOSE cur_emp;
END;
/
```

---

## Opgave 4

Binnen de afdeling HR wil men weten wie al meer dan 20 jaar in dienst is en dus een senior wordt genoemd binnen de afdeling. Vul onderstaande code aan zodat het volgend overzicht wordt getoond:

```bash
Departement: 10
Whalen met een salaris van 4840 is een senior

Departement: 20
Hartstein met een salaris van 13000 is een senior
Fay met een salaris van 6250 is een senior

Departement: 30
Raphely met een salaris van 12100 is een senior
Khoo met een salaris van 3410 is een senior
...
```

```sql
DECLARE
    CURSOR cur_dept IS
        SELECT DISTINCT department_id
        FROM employees
        WHERE department_ID IS NOT NULL
        ORDER BY department_id;
    CURSOR cur_emp .................................................
    v_deptid employees.department_id%TYPE;
    rec_emp cur_emp%ROWTYPE;
    v_months NUMBER(4);
BEGIN
    OPEN cur_dept;
    LOOP
        FETCH cur_dept INTO v_deptid;
        EXIT WHEN cur_dept%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Departement: ' || v_deptid);
    ............................................
        LOOP
            FETCH cur_emp INTO rec_emp;
            EXIT WHEN cur_emp%NOTFOUND;
            v_months := MONTHS_BETWEEN(SYSDATE, rec_emp.hire_date);
            IF v_months > 240 THEN
            DBMS_OUTPUT.PUT_LINE(rec_emp.last_name || ' met een salaris
                van ' || ROUND(rec_emp.salary));
            END IF;
        END LOOP;
        CLOSE cur_emp;
    END LOOP;
    CLOSE cur_dept;
END;
/
```

#### IN TE VULLEN CODE 1

```sql
(p_deptno NUMBER) IS
        SELECT last_name, salary, hire_date
        FROM employees
        WHERE department_id = p_deptno;
```

#### IN TE VULLEN CODE 2

```sql
OPEN cur_emp(v_deptid);
```

---

## Opgave 5

In de tabel employees is department_id een niet-verplicht veld.

Schrijf de nodige code zodat er toch een fout optreedt als een bepaalde employee geüpdatet wordt en zijn department_id op NULL gezet wordt terwijl hij eerder wél een department_id had.
De update mag dan niet doorgaan.

#### Oplossing

```sql
CREATE OR REPLACE TRIGGER aur_emp
AFTER UPDATE of department_id
ON employees
FOR EACH ROW
BEGIN
    IF :NEW.department_id IS NULL AND :OLD.department_Id IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Het departementsnummer moet een waarde bevatten');
    END IF;
END;
/
```

---

## Opgave 6

```bash
SQL> SELECT * FROM countries;

CO  COUNTRY_NAME                     REGION_ID
--  -------------------------------- ---------
AR  Argentina                        2
AU  Australia                        3
BE  Belgium                          1
BR  Brazil                           2
CA  Canada                           2
```

```bash
SQL> SELECT * FROM regions;

REGION_ID  REGION_NAME
---------  -------------------------
1          Europe
2          Americas
3          Asia
4          Middle East and Africa
```

```sql
CREATE OR REPLACE PROCEDURE insert_countries (
p_countryid countries.country_id%TYPE,
p_countryname countries.country_name%TYPE,
p_regionid regions.region_id%TYPE)
IS
BEGIN
    INSERT INTO countries
    VALUES(p_countryid, p_countryname, p_regionid);
    DBMS_OUTPUT.PUT_LINE('Het land dat werd toegevoegd is: ' || p_countryname);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Het land ' || p_countryname || 'kon niet toegevoegd worden');
END;
/
```

### Hoofdprogramma

```sql
BEGIN
    insert_countries('ES','Spain', 1);
    insert_countries('PT','Portugal', 10);
    insert_countries('NO','Norway', 1);
END;
/
```

Gegeven de bovenstaande code.

#### a) Wat zal er afgedrukt worden als de bovenstaande code wordt uitgevoerd?

Het land dat werd toegevoegd is : Spain
Het land Portugal kon niet toegevoegd worden
Het land dat werd toegevoegd is: Norway

#### b) Wat wordt er uiteindelijk weggeschreven in de database?

de gegevens van het land Spain en Norway


---

## Opgave 7

De onderstaande procedure ‘toon_laatste_emp’ zoekt in de medewerkerstabel naar de laatst aangeworven medewerker.

Wat kan er allemaal mislopen bij de uitvoering van deze procedure? Pas de onderstaande code aan zodat de fouten zoveel mogelijk worden opgevangen met eigen specifieke foutmeldingen en de procedure steeds succesvol wordt afgerond.

```sql
CREATE OR REPLACE PROCEDURE toon_laatste_emp
IS
    v_empid employees.employee_id%TYPE;
    v_naam employees.last_name%TYPE;
    v_hiredate employees.hire_date%TYPE;
BEGIN
    SELECT employee_id, last_name, hire_date
    INTO v_empid, v_naam, v_hiredate
    FROM employees
    WHERE hire_date = (SELECT MAX(hire_date)
    FROM employees);
    DBMS_OUTPUT.PUT_LINE ('laatst aangeworven werknemer is ' || v_empid || ' ' || v_naam || ' ' || v_hiredate);
    ...................................
END;
/
```

### IN TE VULLEN CODE

```sql
EXCEPTION
    WHEN too_many_rows THEN
        DBMS_OUTPUT.PUT_LINE('Meer dan 1 persoon gevonden');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Er is een fout opgetreden');
```