set serverout on ver off ;

accept _dest_sqlid       prompt "Destination  SQL_ID: ";
accept _force_match      prompt "Force match  [TRUE]: " default 'true';
accept _prof_description prompt "Profile description: ";

prompt Profile hints source: ;
prompt 1. Enter manually;
prompt 2. From plan table (Explain plan with statement_id);
prompt 3. v$sql_plan;
prompt 4. dba_hist_sql_plan;
accept _src prompt "Choose source[1]: " default 1;

set termout off

col v1 new_val v1 noprint;
col v2 new_val v2 noprint;
col v3 new_val v3 noprint;
col v4 new_val v4 noprint;

select decode(&_src,1,'  ','--') v1
      ,decode(&_src,2,'  ','--') v2
      ,decode(&_src,3,'  ','--') v3
      ,decode(&_src,4,'  ','--') v4
from dual;

def _hints         ='';
def _statement_id  ='';
def _src_sqlid     ='';
def _src_child     ='';
def _src_awr_sqlid ='';
def _src_awr_planhv='';

spool tmp_vars_del.tmp
prompt &v1 accept _hints           prompt "Comma separated hints[example: 'LEADING(P)','USE_CONCAT(@SEL$2)']: ";
prompt &v2 accept _statement_id    prompt "Statement ID: ";
prompt &v3 accept _src_sqlid       prompt "Source SQL_ID: ";
prompt &v3 accept _src_child       prompt "Source child number: ";
prompt &v4 accept _src_awr_sqlid   prompt "Source SQL_ID from AWR: ";
prompt &v4 accept _src_awr_planhv  prompt "Source plan hash value: ";
spool off;
set termout on;
@tmp_vars_del.tmp

declare
    C_SQL_ID          constant varchar2(13)  :='&_dest_sqlid';
    C_PROFILE_NAME    constant varchar2(30)  :='PROF_'||C_SQL_ID;
    C_DESCRIPTION     constant varchar2(30)  :='test profile';
    C_FORCE_MATCH     boolean                :=&_force_match;
    ar_profile_hints  sys.sqlprof_attr;
    cl_sql_text       clob;
    l_other_xml       xmltype;


    function other_xml_to_hints(p_other_xml xmltype) 
       return sys.sqlprof_attr
    as p_hints sys.sqlprof_attr;
    begin
       -- получаем хинты запроса:
       select
           d.hint
           bulk collect into p_hints
       from
           xmltable('/other_xml/outline_data/*'
               passing (p_other_xml)
               columns
               "HINT" varchar2(4000) PATH '/hint'
       ) d;
       return p_hints;
    end other_xml_to_hints;

    $IF &_SRC=2 $THEN
       -- explain plan:
       function get_outlines_from_plan_table(p_statement_id in varchar2)
          return sys.sqlprof_attr 
       is res xmltype;
       begin
          select xmltype(other_xml) into res
          from  plan_table pt
          where pt.statement_id = p_statement_id
            and other_xml is not null;
            
          return other_xml_to_hints(res);
       exception when no_data_found then raise_application_error(-20000,'NO_DATA_FOUND: PLAN_TABLE');
       end;
    $END ------------------------

    $IF &_SRC=3 $THEN
       -- V$SQL_PLAN
       function get_outlines_from_VSQL_PLAN(
                      p_src_sql_id  in varchar2, 
                      p_src_child   in number
          )
          return sys.sqlprof_attr
       is res xmltype;
       begin
          select xmltype(other_xml) into res
          from V$SQL_PLAN p
          where   p.sql_id       = p_src_sql_id
              and p.CHILD_NUMBER = p_src_child
              and p.other_xml is not null;
          return other_xml_to_hints(res);
       exception when no_data_found then raise_application_error(-20000,'NO_DATA_FOUND: V$SQL_PLAN');
       end;
    $END ------------------------
    
    $IF &_SRC=4 $THEN
       -- AWR:
       function get_outlines_from_awr(
                      p_src_sql_id  in varchar2, 
                      p_src_plan_hv in number
          )
          return sys.sqlprof_attr
       is res xmltype;
       begin
          select xmltype(other_xml) into res
          from dba_hist_sql_plan p
          where   p.sql_id = p_src_sql_id
              and p.dbid in (select i.dbid from dba_hist_database_instance i)
              and p.plan_hash_value = p_src_plan_hv
              and p.other_xml is not null;
          return other_xml_to_hints(res);
       exception when no_data_found then raise_application_error(-20000,'NO_DATA_FOUND: AWR');
       end;
    $END ------------------------

begin
    $IF    &_SRC=1 $THEN -- 1. Можем заполнить хинты вручную:
      ar_profile_hints:= sys.sqlprof_attr(&_hints);
    $ELSIF &_SRC=2 $THEN -- 2. или берем аутлайны из plan_table
      ar_profile_hints:= get_outlines_from_plan_table('&_statement_id');
    $ELSIF &_SRC=3 $THEN -- 3. или из v$sql_plan
      ar_profile_hints:= get_outlines_from_VSQL_PLAN('&_src_sqlid',&_src_child);
    $ELSIF &_SRC=4 $THEN -- 4. или из dba_hist_sql_plan:
      ar_profile_hints:= get_outlines_from_awr('&_src_awr_sqlid', &_src_awr_planhv);
    $END
    
    -- Получаем текст запроса:
    select 
      coalesce(
          (select a.sql_fulltext from v$sqlarea a        where a.sql_id = C_SQL_ID and rownum = 1 )
         ,(select t.sql_text     from dba_hist_sqltext t where t.sql_id = C_SQL_ID and rownum = 1 and dbid = (select db.DBID from v$database db))
      ) into cl_sql_text
    from dual;
    
    if cl_sql_text is null then
       raise_application_error(-20000,'SQL_TEXT was not found for sql_id='||C_SQL_ID);
    end if;
    
    dbms_sqltune.import_sql_profile(
         sql_text    => cl_sql_text
        ,profile     => ar_profile_hints
        ,name        => C_PROFILE_NAME
        ,description => C_DESCRIPTION
        ,category    => 'DEFAULT'
        ,replace     => true
        ,force_match => C_FORCE_MATCH
    );

    dbms_output.put_line('=========================================');
    dbms_output.put_line('SQL Profile '||C_PROFILE_NAME||' created.');
    dbms_output.put_line('HINTS:');
    for i in ar_profile_hints.first..ar_profile_hints.last loop
       dbms_output.put_line(ar_profile_hints(i));
    end loop;

end;
/
set serverout off;
undef _hints          ;
undef _statement_id   ;
undef _src_sqlid      ;
undef _src_child      ;
undef _src_awr_sqlid  ;
undef _src_awr_planhv ;

undef _dest_sqlid      ;
undef _force_match     ;
undef _prof_description;

undef _src;
