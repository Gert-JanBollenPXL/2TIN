BEGIN
   FOR i IN 1..10 LOOP
      IF i NOT IN (6, 8) THEN
         INSERT INTO messages (results)
         VALUES (i);
      END IF;
   END LOOP;

SELECT * FROM messages;
END;
/