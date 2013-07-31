set termout off timing off head off 
spool tmp/to_format.sql
select
    coalesce(
        (select sql_fulltext from v$sqlarea a where a.sql_id='&1')
    ,   (select sql_text from dba_hist_sqltext a where a.sql_id='&1' and dbid=(select dbid from v$database))
    ) qtext
from dual
;
spool off
set termout on head on
prompt ################################  Query text Start  ################################################;
host perl ./inc/sql_format.pl tmp/to_format.sql
--$cat tmp/to_format.sql
prompt ################################  Query text End ###################################################
