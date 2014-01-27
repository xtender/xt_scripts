set termout off timing off head off feed off
col qtext format a1500
prompt ################################  Original query text:  ################################################;
spool &_SPOOLS/to_format.sql
select
    coalesce(
        (select sql_fulltext from gv$sqlarea a where a.sql_id='&1' and rownum=1)
    ,   (select sql_text from dba_hist_sqltext a where a.sql_id='&1' and dbid=(select dbid from v$database))
    ) qtext
from dual
;
spool off
col qtext   clear
set termout on head on
prompt ################################  Formatted query text #################################################;
--host perl inc/sql_format_standalone.pl &_SPOOLS/to_format.sql
host java -jar inc/SQLBeautifier.jar &_SPOOLS/to_format.sql
prompt ################################  Formatted query text End #############################################;
