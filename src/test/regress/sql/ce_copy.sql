\! gs_ktool -d all
\! gs_ktool -g

DROP CLIENT MASTER KEY IF EXISTS copyCMK CASCADE;
CREATE CLIENT MASTER KEY copyCMK WITH ( KEY_STORE = gs_ktool , KEY_PATH = "gs_ktool/1" , ALGORITHM = AES_256_CBC);
CREATE COLUMN ENCRYPTION KEY copyCEK WITH VALUES (CLIENT_MASTER_KEY = copyCMK, ALGORITHM = AEAD_AES_256_CBC_HMAC_SHA256);
CREATE TABLE IF NOT EXISTS CopyFromTbl(i0 INT, i1 INT ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = copyCEK, ENCRYPTION_TYPE = DETERMINISTIC) , i2 INT);
COPY copyfromtbl FROM stdin;
5	10	7
20	20	8
30	10	12
50	35	12
80	15	23
\.
-- fail   error
COPY copyfromtbl FROM stdin;
1	2	3	4
\.

SELECT * FROM CopyFromTbl ORDER BY i0;

COPY copyfromtbl (i0, i1,i2) FROM stdin;
5	10	7
20	20	8
30	10	12
50	35	12
80	15	23
\.
SELECT * FROM CopyFromTbl ORDER BY i0;

\copy CopyFromTbl FROM 'ce_copy_from.csv' WITH DELIMITER ',' CSV HEADER;
SELECT * FROM CopyFromTbl ORDER BY i0;
\copy (SELECT * FROM CopyFromTbl ORDER BY i2) TO 'ce_copy_to.csv' WITH DELIMITER ',' CSV HEADER;

copy CopyFromTbl FROM 'ce_copy_from.csv' WITH DELIMITER ',' CSV HEADER;
copy CopyFromTbl (i0, i1,i2) FROM 'ce_copy_from.csv' WITH DELIMITER ',' CSV HEADER;
copy CopyFromTbl TO 'ce_copy_to.csv' WITH DELIMITER ',' CSV HEADER;
copy (SELECT * FROM CopyFromTbl ORDER BY i2) TO 'ce_copy_to.csv' WITH DELIMITER ',' CSV HEADER;

CREATE TABLE IF NOT EXISTS CopyTOTbl(i0 INT, i1 INT ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY=copyCEK, ENCRYPTION_TYPE = DETERMINISTIC) , i2 INT);
\copy CopyToTbl FROM 'ce_copy_to.csv' WITH DELIMITER ',' CSV HEADER;
SELECT * FROM CopyToTbl ORDER BY i0;
COPY (SELECT * FROM CopyFromTbl ORDER BY i0) TO stdout;

DROP TABLE CopyFromTbl;
DROP TABLE CopyToTbl;
DROP CLIENT MASTER KEY copyCMK CASCADE;

\! gs_ktool -d all