accept _dblink    prompt "Enter source database: ";
accept _sqlid     prompt "Enter source sql_id: ";
accept _plan_hv   prompt "Enter source plan_hash_value: ";
accept _descr     prompt "Enter description: ";

var sql_id           varchar2(13);
var plan_hash_value  number
var description      varchar2(60);

exec :sql_id := '&_sqlid';
exec :plan_hash_value := &_plan_hv;
exec :description     := '&_descr';


set serverout on;
declare
    ar_profile_hints    sys.sqlprof_attr;
    cl_sql_text         clob;
    l_profile_name      varchar2(30):='PROF_'||:sql_id;
    l_dbid              number;
    l_force_match       boolean:=true;
begin
    -- vars:
    select dbid into l_dbid from v$database;
    
   --ar_profile_hints:=sys.sqlprof_attr('LEADING(P)','USE_CONCAT(@SEL$2)');
   --/*
   -- source hints:
   
   insert into xt_clob_tmp 
   select plan_hash_value,other_xml 
   from gv$sql_plan@&_dblink
   where
        sql_id = :sql_id
        and plan_hash_value = :plan_hash_value
        and other_xml is not null
        and id=1
        and rownum=1;
   
    select
        d.hint
        bulk collect into ar_profile_hints
    from
        xmltable('/other_xml/outline_data/*'
            passing (
                select
                    xmltype(c) as xmlval
                from
                    xt_clob_tmp
                where
                    id = :plan_hash_value
            )
            columns
            "HINT" varchar2(4000) PATH '/hint'
    ) d;
    --*/
    -- Showing:
    for i in ar_profile_hints.first..ar_profile_hints.last loop
       dbms_output.put_line(ar_profile_hints(i));
    end loop;
    -- SQL_TEXT:
    select 
       coalesce(
          (select s1.sql_fulltext from v$sqlarea        s1 where :sql_id = s1.sql_id)
         ,(select s2.sql_text     from dba_hist_sqltext s2 where :sql_id = s2.sql_id and s2.dbid = l_dbid)
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
        ,force_match => l_force_match
    );

    dbms_output.put_line(' ');
    dbms_output.put_line('SQL Profile '||l_profile_name||' created on instance #'||sys_context('userenv','instance'));
    dbms_output.put_line(' ');

exception
when NO_DATA_FOUND then
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||:sql_id||' not found in AWR.');
  dbms_output.put_line(' ');

end;
/
set serverout off;
