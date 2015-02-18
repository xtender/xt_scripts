----------------------------------------------------------------------------------------
--
-- File name:   create_sql_profile_awr.sql
--
-- Purpose:     Create SQL Profile based on Outline hints from AWR.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for five values.
--
--              sql_id: the sql_id of the statement to attach the profile to 
--              (must be in the shared pool and in AWR history)
--
--              plan_hash_value: the plan_hash_value of the statement in AWR history
--
--              profile_name: the name of the profile to be generated
--
--              category: the name of the category for the profile
--
--              force_macthing: a toggle to turn on or off the force_matching feature
--
-- Description: 
--
--              Based on a script by Randolf Giest.
--
-- Mods:        This is the 2nd version of this script which removes dependency on rg_sqlprof2.sql.
--              Modified for AWR.// Sayan Malakshinov http://orasql.org
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--

-- @rg_sqlprof1 '&&sql_id' &&child_no '&&category' '&force_matching'

set feedback off
set serverout on

accept sql_id -
       prompt 'Enter value for sql_id: ' -
       default 'X0X0X0X0'

col plan_hv new_val _plan_hv
with t as (
select/*+ SQLSTAT */
                        st.snap_id
                       ,st.instance_number                                                                                        as inst_id
                       ,snaps.begin_interval_time                                                                                 as time_start
                       ,snaps.end_interval_time                                                                                   as time_end
                       ,st.dbid
                       ,st.plan_hash_value                                                                                        as plan_hv
                       ,to_char(decode(st.executions_delta,0,0,st.elapsed_time_delta / 1e6 / st.executions_delta),'999999.99990') as elaexe
                       ,to_char(decode(st.executions_delta,0,0,st.cpu_time_delta     / 1e6 / st.executions_delta),'999999.99990') as elacpu
                       ,to_char(decode(st.executions_delta,0,0,st.iowait_delta       / 1e6 / st.executions_delta),'999999.99990') as ela_io
                       ,to_char(decode(st.executions_delta,0,0,st.apwait_delta       / 1e6 / st.executions_delta),'999999.99990') as ela_app
                       ,to_char(decode(st.executions_delta,0,0,st.PLSEXEC_TIME_DELTA / 1e6 / st.executions_delta),'999999.99990') as ela_pls
                       ,to_char(decode(st.executions_total,0,0,st.elapsed_time_total / 1e6 / st.executions_total),'999999.99990') as all_elaexe
                       ,st.executions_delta                                                                                       as cnt 
                       ,st.executions_total                                                                                       as all_cnt
                       ,to_char(decode(st.executions_delta,0,0,st.buffer_gets_delta / st.executions_delta ),'99g999g999d90',q'[nls_numeric_characters='.`']') buf_gets_per_exec
                       ,to_char(decode(st.executions_delta,0,0,st.disk_reads_delta / st.executions_delta ),'999999.90')           as disk_reads_per_exec
                       ,st.sql_profile
                       ,to_char(decode(st.executions_delta,0,0,st.ROWS_PROCESSED_DELTA          /  st.executions_delta),'99999999.0')   as ROWS_PROCESSED_D
from v$database db
    ,dba_hist_sqlstat st
    ,dba_hist_snapshot snaps
where 
      snaps.dbid            = db.dbid
  and snaps.instance_number = userenv('instance')
  and st.sql_id             = '&sql_id'
  and st.dbid               = db.dbid
  and st.snap_id            = snaps.snap_id
--  and st.instance_number    = snaps.instance_number
  and st.executions_delta   > 0
order by 1 desc
)
,t2 as (
   select *
   from t
   where rownum<=20
)
select
  plan_hv
 ,min(time_start)       as time_start
 ,max(time_end)         as time_end
 ,max(sql_profile)      as sql_profile
 ,avg(elaexe)           as elaexe_avg
 ,min(elaexe)           as elaexe_min
 ,max(elaexe)           as elaexe_max
 ,avg(ROWS_PROCESSED_D) as rows_avg
 ,min(ROWS_PROCESSED_D) as rows_min
 ,max(ROWS_PROCESSED_D) as rows_max
 ,sum(cnt)         as cnt
from t2
group by plan_hv
order by elaexe_avg desc
;
col plan_hv clear;

accept plan_hash_value -
       prompt 'Enter value for plan_hash_value[&_plan_hv]: ' default &_plan_hv
accept profile_name -
       prompt 'Enter value for profile_name [PROF_&SQL_ID]: ' -
       default 'PROF_&SQL_ID'
accept category -
       prompt 'Enter value for category (DEFAULT): ' -
       default 'DEFAULT'
accept force_matching -
       prompt 'Enter value for force_matching (TRUE): ' -
       default 'true'

declare
    ar_profile_hints sys.sqlprof_attr;
    cl_sql_text clob;
    l_profile_name varchar2(30):='&profile_name';
begin
    select
        extractvalue(value(d), '/hint') as outline_hints
        bulk collect into ar_profile_hints
    from
        xmltable('/*/outline_data/hint'
            passing (
                select
                    xmltype(other_xml) as xmlval
                from
                    dba_hist_sql_plan
                where
                    sql_id = '&&sql_id'
                    and plan_hash_value = &&plan_hash_value
                    and other_xml is not null
                    and dbid = (select dbid from v$database)
            )
        ) d;

    select sql_text
           into cl_sql_text
    from   dba_hist_sqltext
    where  sql_id = '&&sql_id';

    dbms_sqltune.import_sql_profile(
        sql_text    => cl_sql_text,
        profile     => ar_profile_hints,
        category    => '&&category',
        name        => l_profile_name,
        force_match => &&force_matching,
        replace => true
    );

    dbms_output.put_line(' ');
    dbms_output.put_line('SQL Profile '||l_profile_name||' created.');
    dbms_output.put_line(' ');

exception
when NO_DATA_FOUND then
  dbms_output.put_line('**********');
  dbms_output.put_line('ERROR: sql_id: '||'&&sql_id'||' Plan: '||'&&plan_hash_value'||' not found in AWR.');
  dbms_output.put_line('**********');

end;
/

undef sql_id
undef plan_hash_value
undef profile_name
undef category
undef force_matching

set feedback on
set serverout off
