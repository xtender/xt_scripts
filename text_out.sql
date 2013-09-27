set termout off timing off head off
col qtext format a1500
prompt ################################  Original query text:  ################################################;
spool tmp/to_format.sql
select
    coalesce(
        (select sql_fulltext from v$sqlarea a where a.sql_id='&1')
    ,   (select sql_text from dba_hist_sqltext a where a.sql_id='&1' and dbid=(select dbid from v$database))
    ) qtext
from dual
;
spool off
col qtext   clear
set termout on head on
host &_START tmp/to_format.sql