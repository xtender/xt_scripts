@sqlplus_store

accept _sql_id    prompt 'Enter SQL_ID: ';
accept _outline   prompt 'Enter outline hints: ';
accept _format    prompt 'Enter format[html/text, default: html]' default 'html';

var v_path varchar2(100);

declare
   v_sql_id   v$sql.sql_id%type:='&_sql_id';
   v_outline1 clob:=' ';
   v_outline2 clob:=q'[&_outline]';
   v_format   varchar2(4):='&_format'; --'text';
   
   v_stmt     clob;
   v_username v$sql.parsing_schema_name%type;

   v_id       varchar2(100);
   v_ref_id   varchar2(100);


begin
   select sql_fulltext , a.PARSING_SCHEMA_NAME
     into v_stmt       , v_username
   from v$sqlarea a 
   where a.sql_id = v_sql_id;
   v_id     := dbms_xplan.diff_plan_outline(
                                             v_stmt
                                           , v_outline1
                                           , v_outline2
                                           , v_username
                                           );
   v_ref_id := regexp_substr(v_id,'TASK_(.*)',1,1,'i',1);
   :v_path   := '/orarep/plandiff/all?'
                  ||'task_id=' || v_ref_id 
                  ||'&'
                  ||'format='  || v_format
                  ||'&'
                  ||'method=qbreg';
end;
/
set termout off feed off ver off head off;

spool &_SPOOLS./compare_&_sql_id..html
select dbms_report.get_report( :v_path ) from dual;
spool off

host &_START &_SPOOLS./compare_&_sql_id..html
@sqlplus_restore
