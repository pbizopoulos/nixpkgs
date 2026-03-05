.mode list
.header off
SELECT CASE
    WHEN (1 + 1) = 2 THEN 'test ... ok'
    ELSE 'test math failed'
END;
