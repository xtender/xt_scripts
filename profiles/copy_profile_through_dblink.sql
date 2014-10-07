set feed on serverout on;

accept _dblink    prompt "Enter source database: ";
accept _profile   prompt "Enter source profile_name: ";
accept _sqlid     prompt "Enter source sql_id[null]: ";
accept _descr     prompt "Enter description: ";

var sql_id          varchar2(13);
var profile_name    varchar2(30);
var db_link         varchar2(45);
var description     varchar2(50);

exec :db_link       := '&_dblink';
exec :profile_name  := '&_profile';
exec :sql_id        := '&_sqlid';
exec :description   := '&_descr';

declare
    ar_profile_hints       sys.sqlprof_attr;
    cl_sql_text            clob;
    l_profile_name         varchar2(30);
    l_dblink               varchar2(30);
    e_profile_not_exists   exception;
    pragma exception_init(e_profile_not_exists ,-13833);

    ---------------------------------------------------
    -- create_clob_gtt
    procedure create_clob_gtt is
       e_gtt_exists exception;
       pragma exception_init(e_gtt_exists,-00955);
    begin
       execute immediate 'create global temporary table xt_clob_tmp(id int, c clob) on commit preserve rows';
    exception 
       when e_gtt_exists then 
          execute immediate 'delete from xt_clob_tmp';
          commit;
    end create_clob_gtt;
    ---------------------------------------------------
    -- get_hints_11
    function get_hints_11(p_profile_name varchar2, db_link varchar2 default null) 
       return sys.sqlprof_attr
    is
       res          sys.sqlprof_attr;
       l_sql_insert varchar2(32000):=q'[
                    insert into xt_clob_tmp(id,c)
                     select 2, sd.comp_data
                     from sys.sqlobj$    ]'||db_link||q'[ p
                         ,sys.sqlobj$data]'||db_link||q'[ sd
                     where p.name      = :profile_name
                       and p.signature = sd.signature 
                       and p.category  = sd.category
                       and p.obj_type  = sd.obj_type
                       and p.plan_id   = sd.plan_id]';
       
       l_sql_hints   varchar2(32000):=q'[
                     select--+ NO_XML_QUERY_REWRITE
                        x.hint as outline_hints 
                     from xt_clob_tmp t
                         ,xmltable('/outline_data/hint' 
                                   passing xmltype(t.c)
                                   columns hint varchar2(500) path '.'
                                  ) x
                     where t.id=2]';
    begin
       execute immediate l_sql_insert 
          using p_profile_name;
       execute immediate l_sql_hints  
          bulk collect into res;
       return res;
    exception when others then 
       dbms_output.put_line('Error [get_hints_11]: '||sqlerrm); 
       raise;
    end get_hints_11;
    ---------------------------------------------------
    -- get_hints_10
    function get_hints_10(p_profile_name varchar2, db_link varchar2 default null) 
       return sys.sqlprof_attr
    is
       l_version number;
       res       sys.sqlprof_attr;
       l_sql     varchar2(32000):=q'[
                     select  attr_val as outline_hints 
                     from dba_sql_profiles]'||db_link||q'[ p
                         ,sys.sqlprof$attr]'||db_link||q'[ h 
                     where 
                          p.name      = :profile_name
                      and p.category  = h.category  
                      and p.signature = h.signature]';
       
    begin
       execute immediate l_sql bulk collect into res using p_profile_name;
       return res;
    exception when others then 
       dbms_output.put_line('Error [get_hints_10]: '||sqlerrm); 
       raise;
    end;
    
    function get_hints(p_profile_name varchar2, db_link varchar2 default null) 
       return sys.sqlprof_attr
    is
       l_version number;
       res sys.sqlprof_attr;
    begin
       begin
       execute immediate 
          q'[select substr(version,1,instr(version,'.')-1) from v$instance]'||db_link 
          into l_version;
       exception when others then dbms_output.put_line(q'[select substr(version,1,instr(version,'.')-1) from v$instance]'||db_link );
       end;
       
       case 
          when l_version = 10 then  res:= get_hints_10(p_profile_name,db_link);
          when l_version>= 11 then  res:= get_hints_11(p_profile_name,db_link);
          else raise_application_error(-20001,'Unsupported version!');
       end case;

       if res.count()=0 then raise_application_error(-20001,'Hints not found!'); end if;
       return res;
    end get_hints;
begin
    -- temporary table for clobs
    create_clob_gtt();
    
    l_dblink:=case when :db_link like '@%' then :db_link else '@'||:db_link end;
    -- prof_name:
    l_profile_name := case when :sql_id is not null then 'PROF_'||:sql_id
                           else :profile_name
                      end;

    -- hints:
    ar_profile_hints:=get_hints(:profile_name,l_dblink);


    dbms_output.put_line('Hints:');
    
    for i in ar_profile_hints.first..ar_profile_hints.last loop
      dbms_output.put_line(ar_profile_hints(i));
    end loop;
    --select sql_text into cl_sql_text from dba_sql_profiles s where s.name like 'PROF_0p9cafpym6420';

    -- query text:
    if :sql_id is not null 
       then
          select a.sql_fulltext into cl_sql_text from v$sqlarea a where a.sql_id=:sql_id;
       else   
          execute immediate 
               'insert into xt_clob_tmp(id,c)
                select 1, p.sql_text 
                from dba_sql_profiles'||l_dblink||' p 
                where p.name=:profile_name' 
                using :profile_name;
          execute immediate 'select c from xt_clob_tmp where id=1' 
             into cl_sql_text;
    end if;

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
undef _dblink  ;
undef _profile ;
undef _sqlid   ;
undef _descr   ;
commit;
set feed off serverout off;