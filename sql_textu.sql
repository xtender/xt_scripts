col qtext format a150
prompt ################################  Original query text:  ################################################;
select
    coalesce(
        (select sql_fulltext from v$sqlarea a where a.sql_id='&1')
    ,   (select sql_text from dba_hist_sqltext a where a.sql_id='&1' and dbid=(select dbid from v$database))
    ) qtext
from dual
;
