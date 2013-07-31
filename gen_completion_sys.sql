@sqlplus_store

prompt Generating completion list for public and sys objects...

set termout off head off feed off timing off
set lines 300 trimspool on pages 0 head off feedback off termout off

SELECT DISTINCT name FROM (
    select lower(keyword) name                     from v$reserved_words union all
    select upper(table_name)                       from dict union all
    select table_name||'.'||column_name            from dict_columns union all
    -- select object_name from dba_objects union all
    select upper(object_name||'.'||procedure_name) from dba_procedures where owner='SYS' union all
    -- select '"'||table_name||'".'||column_name from dba_tab_columns union all
    select ksppinm                                 from x$ksppi  where ksppinm like '_optim%' union all
    select name                                    from v$sql_hint
)
WHERE length(name) > 2
ORDER BY 1
.

def _FILE=&_SPOOLS./rlwrap.all.completions.txt

spool &_FILE
/
spool off

set term on
prompt File path: &_FILE
undef _FILE
@sqlplus_restore