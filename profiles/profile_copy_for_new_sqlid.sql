set feed on serverout on;

accept _profile   prompt "Enter source profile_name: ";
accept _sqlid     prompt "Enter dest sql_id: ";
accept _descr     prompt "Enter description[Copy of &_profile]: " default 'Copy of &_profile';

var sql_id          varchar2(13);
var profile_name    varchar2(30);
var db_link         varchar2(45);
var description     varchar2(50);

begin
 :profile_name  := '&_profile';
 :sql_id        := '&_sqlid';
 :description   := '&_descr';
end;
/
declare
    ar_profile_hints       sys.sqlprof_attr;
    cl_sql_text            clob;
    l_profile_name         varchar2(30);
    l_dblink               varchar2(30);
    e_profile_not_exists   exception;
    pragma exception_init(e_profile_not_exists ,-13833);

    ---------------------------------------------------
    -- get_hints
    function get_hints(p_profile_name varchar2) 
       return sys.sqlprof_attr
    is
       res          sys.sqlprof_attr;
    begin
       $IF dbms_db_version.version = 11 $THEN
          select--+ NO_XML_QUERY_REWRITE
             x.hints
             bulk collect into res
          from sys.sqlobj$ p
              ,sys.sqlobj$data sd
              ,xmltable('/outline_data/hint' 
                        passing xmltype(sd.comp_data)
                        columns 
                           n     for ordinality,
                           hints varchar2(200) path '.'
                       ) x
          where
               p.name = p_profile_name
           and p.signature = sd.signature 
           and p.category  = sd.category
           and p.obj_type  = sd.obj_type
           and p.plan_id   = sd.plan_id
          order by x.n;
       $ELSE
          select
             attr_val as hints 
             bulk collect into res
          from 
               dba_sql_profiles p
              ,sys.sqlprof$attr h 
          where 
               p.name)     = p_profile_name
           and p.category  = h.category  
           and p.signature = h.signature
          order by    p.name,h.attr#
          ;
       $END

       return res;
    exception when others then 
       dbms_output.put_line('Error [get_hints]: '||sqlerrm); 
       raise;
    end get_hints;
    ---------------------------------------------------
begin
    -- prof_name:
    l_profile_name := 'PROF_'||:sql_id;

    -- hints:
    ar_profile_hints:=get_hints(:profile_name);

    dbms_output.put_line('Hints:');
    
    for i in ar_profile_hints.first..ar_profile_hints.last loop
      dbms_output.put_line(ar_profile_hints(i));
    end loop;

    -- query text:
    select 
       coalesce(
          (select s1.sql_fulltext from v$sqlarea        s1 where :sql_id = s1.sql_id)
         ,(select s2.sql_text     from dba_hist_sqltext s2 where :sql_id = s2.sql_id and s2.dbid = (select dbid from v$database))
       ) stext
       into cl_sql_text
    from dual;

    dbms_sqltune.import_sql_profile(
         sql_text    => cl_sql_text
        ,profile     => ar_profile_hints
        ,name        => l_profile_name
        ,description => :description
        ,category    => 'DEFAULT'
        ,replace     => true
        ,force_match => true
    );
    dbms_output.put_line(' ');
    dbms_output.put_line('SQL Profile '||l_profile_name||' created.');
    dbms_output.put_line(' ');
exception
    when NO_DATA_FOUND then
      dbms_output.put_line(' ');
      dbms_output.put_line('ERROR: sql_id: '||:sql_id||' SQL_ID not found .');
      raise_application_error(-20001, 'ERROR: sql_id: '||:sql_id||' SQL_ID not found .');
      dbms_output.put_line(' ');
   when others then 
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/
undef _profile ;
undef _sqlid   ;
undef _descr   ;
commit;
set feed off serverout off;
