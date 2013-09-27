set serverout on;
accept _sqlid     prompt 'Enter value for sql_id: '               default 'X0X0X0X0';
accept _prof_name prompt 'Enter sql profile name:[PROF_&_sqlid]'  default 'PROF_&_sqlid';
accept _hints     prompt 'Enter comma separated hints: '          default "'IGNORE_OPTIM_EMBEDDED_HINTS'";
accept _descr     prompt 'Enter description: '          ;

declare
    l_sqlid           varchar2(13)     := '&_sqlid';
    l_profile         varchar2(30)     := '&_prof_name';
    l_hints           sys.sqlprof_attr := sys.sqlprof_attr( &_hints );
    l_force_match     boolean          := true;
    l_descr           varchar2(500)    := '&_descr';
    l_category        varchar2(30)     := 'DEFAULT';
    
    cl_sql_text            clob;
    l_dbid                 number;
    e_profile_not_exists   exception;
    pragma exception_init(e_profile_not_exists ,-13833);
begin
    -- Удаляем профиль если есть:
    begin
       dbms_sqltune.drop_sql_profile(l_profile);
    exception 
       when e_profile_not_exists then 
          null;
    end;
    -- заполняем исходные переменные:
    select dbid into l_dbid from v$database;
    -- Получаем текст запроса:
    select 
       coalesce(
          (select s1.sql_fulltext from v$sqlarea        s1 where l_sqlid = s1.sql_id)
         ,(select s2.sql_text     from dba_hist_sqltext s2 where l_sqlid = s2.sql_id and s2.dbid = l_dbid)
       ) stext
       into cl_sql_text
    from dual;

    -- Выводим хинты:
    dbms_output.put_line('Hints:');
    for i in l_hints.first..l_hints.last loop
      dbms_output.put_line(l_hints(i));
    end loop;

    dbms_sqltune.import_sql_profile(
         sql_text    => cl_sql_text
        ,profile     => l_hints
        ,name        => l_profile
        ,description => l_descr
        ,category    => l_category
        ,replace     => true
        ,force_match => l_force_match
    );

    dbms_output.put_line('****************************');
    dbms_output.put_line('SQL Profile '||l_profile||' created.');
    dbms_output.put_line('****************************');

exception
   when NO_DATA_FOUND then
     dbms_output.put_line('****************************');
     dbms_output.put_line('ERROR: sql_id: '||l_sqlid||' SQL_ID not found .');

end;
/
set serverout off;
