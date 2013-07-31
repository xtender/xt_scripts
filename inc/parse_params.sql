@inc/input_vars_init;
set termout off head off feed off timing off;
spool &_TEMPDIR./tmp.sql
with t as
( select column_value s 
  from 
  table(sys.odcivarchar2list('&1','&2','&3','&4','&5','&6','&7','&8','&9','&10','&11','&12'))
)
select 
   'DEF '|| regexp_substr(s, '^[^=]+') || ' = '|| regexp_substr(s, '[^=]+$')
from t
where s like '%=%';
spool off
@&_TEMPDIR./tmp.sql
set termout on head on feed on timing on;
select * from dual;
@inc/input_vars_undef;