prompt ***;
prompt Using SQL Patch to add hints;
prompt ***;

set feed on serverout on;

accept p_sqlid      prompt "SQL_ID: ";
accept p_hints      prompt "Hints: ";
accept p_name       prompt "Patch name: ";
accept p_descr      prompt "Description: ";

declare
   -- params:
   p_sql_id         varchar2(13)  :=q'[&p_sqlid]';
   p_hints          varchar2(4000):=q'[&p_hints]';
   p_name           varchar2(30)  :=q'[&p_name]';
   p_description    varchar2(120) :=q'[&p_descr]';
   cl_sql_text      clob;
begin
   
    select 
       coalesce(
          (select s1.sql_fulltext from v$sqlarea        s1 where p_sql_id = s1.sql_id)
         ,(select s2.sql_text     from dba_hist_sqltext s2 where p_sql_id = s2.sql_id and s2.dbid = (select db.dbid from v$database db))
       ) stext
       into cl_sql_text
    from dual;
    
   sys.dbms_sqldiag_internal.i_create_patch(
      sql_text    => cl_sql_text,
      hint_text   => p_hints,
      name        => p_name,
      description => p_description
   );
   
   dbms_output.put_line('SQL Profile '||p_name||' created on instance #'||sys_context('userenv','instance'));
end;
/
undef p_sqlid p_hints p_name p_descr
