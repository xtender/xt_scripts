col stext format a90
select sql_id,substr(sql_text,1,90) stext from v$sqlarea a where a.sql_id like '&1';
col stext clear;