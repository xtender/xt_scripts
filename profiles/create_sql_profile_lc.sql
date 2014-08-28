set feed on serverout on;

accept sqlid   prompt "SQL_ID: ";

col sql_id format a13;
col plan_hash_value new_val plan_hv;
select 
    s.sql_id
  , s.plan_hash_value
  , s.elapsed_time/1e6/nullif(s.executions,0) as elaexe
  , s.executions 
from v$sql s
where s.sql_id='&sqlid'
order by elaexe desc;
accept plan_hv prompt "Plan hash value[&plan_hv]: " default "&plan_hv";
col sql_id          clear;
col plan_hash_value clear;

accept force_match prompt "Force_match[1]: " default 1;
accept description prompt "Description[from lc]: " default "from lc";
accept category    prompt "Category[DEFAULT]: " default "DEFAULT";


declare
   -- params:
    p_sql_id          varchar2(13):= '&sqlid';
    p_plan_hash_value number:=&plan_hv+0;
    p_force_match     int:= nvl(&force_match+0,1);
    p_description     varchar2(50):=nvl('&description','profile for &sqlid');
    p_category        varchar2(30):=nvl('&category','DEFAULT');
    
    -- end params
    
    ar_profile_hints sys.sqlprof_attr;
    cl_sql_text      clob;
    l_profile_name   varchar2(30);
    l_dbid           number;
    l_force_match    boolean;
    
    e_privs          exception;
    pragma exception_init(e_privs, -38171);
    
    procedure br is
    begin
       dbms_output.put_line('*');
    end br;
    
    procedure hr is
    begin
       dbms_output.put_line('========================================================');
    end hr;
begin
    -- заполняем исходные переменные:
    select dbid into l_dbid from v$database;
--    l_dbid := :dbid;
    
    l_profile_name := 'PROF_'||p_sql_id;
    l_force_match:=case p_force_match 
                        when 1 then TRUE
                        else false
                   end;
   begin
      dbms_sqltune.drop_sql_profile(l_profile_name);
   exception when others then
      null;
   end;
   --ar_profile_hints:=sys.sqlprof_attr('LEADING(P)','USE_CONCAT(@SEL$2)');
   --/*
   -- получаем хинты запроса:
    select
        d.hint
        bulk collect into ar_profile_hints
    from
        xmltable('/other_xml/outline_data/*'
            passing (
                select
                    xmltype(other_xml) as xmlval
                from
                    gv$sql_plan
                where
                    sql_id = p_sql_id
                    and plan_hash_value = p_plan_hash_value
                    and other_xml is not null
                    and id=1
                    and rownum=1
            )
            columns
            "HINT" varchar2(4000) PATH '/hint'
    ) d;
    --*/
    if ar_profile_hints is null or ar_profile_hints.count() = 0 then 
        raise_application_error(-20000,'Hints was not captured from gv$sql_plan!');
    end if;
    hr;
    dbms_output.put_line('*  Profile Hints:');
    br;
    for i in ar_profile_hints.first..ar_profile_hints.last loop
       dbms_output.put_line(ar_profile_hints(i));
    end loop;
    -- Получаем текст запроса:
    select 
       coalesce(
          (select s1.sql_fulltext from v$sqlarea        s1 where p_sql_id = s1.sql_id)
         ,(select s2.sql_text     from dba_hist_sqltext s2 where p_sql_id = s2.sql_id and s2.dbid = l_dbid)
       ) stext
       into cl_sql_text
    from dual;
    
    dbms_sqltune.import_sql_profile(
         sql_text    => cl_sql_text
        ,profile     => ar_profile_hints
        ,name        => l_profile_name
        ,description => p_description
        ,category    => nvl(p_category,'DEFAULT')
        ,replace     => true
        ,force_match => l_force_match
    );
    
    hr;
  br;
    dbms_output.put_line('SQL Profile '||l_profile_name||' created on instance #'||sys_context('userenv','instance'));
  br;

exception
   when E_PRIVS then
      br;
      dbms_output.put_line('ERROR: ORA-38171: Insufficient privileges for SQL management object operation!');
      br;
   when NO_DATA_FOUND then
     br;
     dbms_output.put_line('ERROR: sql_id: '||p_sql_id||' not found in LC.');
     br;

end;
/
undef sqlid plan_hv force_match description category;
set feed off serverout off;
