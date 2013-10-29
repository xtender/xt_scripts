set timing off head off
col qtext format a150
prompt ################################  Original query text:  ################################################;
spool &_SPOOLS/to_format.sql
select
    coalesce(
        (select sql_fulltext from v$sqlarea a where a.sql_id='&1')
    ,   (select sql_text from dba_hist_sqltext a where a.sql_id='&1' and dbid=(select dbid from v$database))
    ) qtext
from dual
;
spool off

prompt ################################  Formatted query text #################################################;
host perl inc/sql_format_standalone.pl &_SPOOLS/to_format.sql
prompt ################################  Formatted query text End #############################################;
set termout on head on