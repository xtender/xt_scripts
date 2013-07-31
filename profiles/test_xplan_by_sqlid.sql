declare 
   v_text   varchar2(32767);
   v_sql_id varchar2(13):='&1';
begin
   select 
      coalesce(
          (select a.SQL_FULLTEXT from v$sqlarea        a where a.sql_id = v_sql_id and rownum=1)
         ,(select t.SQL_TEXT     from dba_hist_sqltext t where t.sql_id = v_sql_id and t.dbid=(select db.dbid from v$database db))
      )
      into v_text
   from dual;
   v_text:='explain plan for '||v_text;
   execute immediate v_text;
end;
/
@xplan
