--
-- SELECT_INTO
--

SELECT *
   INTO TABLE tmp1
   FROM onek
   WHERE onek.unique1 < 2;

DROP TABLE tmp1;

SELECT *
   INTO TABLE tmp1
   FROM onek2
   WHERE onek2.unique1 < 2;

DROP TABLE tmp1;

--
-- SELECT INTO and INSERT permission, if owner is not allowed to insert.
--
CREATE SCHEMA selinto_schema;
CREATE USER selinto_user PASSWORD 'ttest@123';
ALTER DEFAULT PRIVILEGES FOR ROLE selinto_user
	  REVOKE INSERT ON TABLES FROM selinto_user;
GRANT ALL ON SCHEMA selinto_schema TO public;

SET SESSION AUTHORIZATION selinto_user PASSWORD 'ttest@123';
SELECT * INTO TABLE selinto_schema.tmp1
	  FROM pg_class WHERE relname like '%a%';	-- Error
SELECT oid AS clsoid, relname, relnatts + 10 AS x
	  INTO selinto_schema.tmp2
	  FROM pg_class WHERE relname like '%b%';	-- Error
CREATE TABLE selinto_schema.tmp3 (a,b,c)
	   AS SELECT oid,relname,relacl FROM pg_class
	   WHERE relname like '%c%';	-- Error
RESET SESSION AUTHORIZATION;

ALTER DEFAULT PRIVILEGES FOR ROLE selinto_user
	  GRANT INSERT ON TABLES TO selinto_user;

SET SESSION AUTHORIZATION selinto_user PASSWORD 'ttest@123';
SELECT * INTO TABLE selinto_schema.tmp1
	  FROM pg_class WHERE relname like '%a%';	-- OK
SELECT oid AS clsoid, relname, relnatts + 10 AS x
	  INTO selinto_schema.tmp2
	  FROM pg_class WHERE relname like '%b%';	-- OK
CREATE TABLE selinto_schema.tmp3 (a,b,c)
	   AS SELECT oid,relname,relacl FROM pg_class
	   WHERE relname like '%c%';	-- OK
RESET SESSION AUTHORIZATION;

DROP SCHEMA selinto_schema CASCADE;
DROP USER selinto_user;

--
-- CREATE TABLE AS/SELECT INTO as last command in a SQL function
-- have been known to cause problems
--
CREATE FUNCTION make_table() RETURNS VOID
AS $$
  CREATE TABLE created_table AS SELECT * FROM int8_tbl;
$$ LANGUAGE SQL;

SELECT make_table();

SELECT * FROM created_table;

DROP TABLE created_table;

--
-- Disallowed uses of SELECT ... INTO.  All should fail
--
CURSOR foo FOR SELECT 1 INTO b;
COPY (SELECT 1 INTO frak UNION SELECT 2) TO 'blob';
SELECT * FROM (SELECT 1 INTO f) bar;
CREATE VIEW foo AS SELECT 1 INTO b;
INSERT INTO b SELECT 1 INTO f;

--
-- EXPLAIN ANALYZE CREATE TABLE AS/SELECT INTO
--
CREATE TABLE tmp_table(a int, b int);
INSERT INTO tmp_table VALUES (1,1),(2,2);

EXPLAIN SELECT * INTO select_into_tbl FROM tmp_table;
EXPLAIN ANALYZE SELECT * INTO select_into_tbl FROM tmp_table;

SELECT count(*) FROM select_into_tbl;
DROP TABLE select_into_tbl;

EXPLAIN CREATE TABLE ctas_tbl AS SELECT * FROM tmp_table;
EXPLAIN ANALYZE CREATE TABLE ctas_tbl AS SELECT * FROM tmp_table;

SELECT count(*) FROM ctas_tbl;
DROP TABLE ctas_tbl;

DROP TABLE tmp_table;
