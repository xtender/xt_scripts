@inc/input_vars_init;
-----------------------------------------
--    params check:
set termout off timing off
def _sqlid=&1
col _ROWNUM new_val _ROWNUM noprint
select 
   case 
      when translate('&2','x0123456789','x') is null  
         then nvl('&2','20') 
      else '20'
   end "_ROWNUM"
from dual;
-----------------------------------------
set termout on

prompt &_C_REVERSE.SQLSTAT by sqlid=&1 for last &_ROWNUM rows...&_C_RESET

REM ############### COMMON FORMATTING #######################
col SQL_ID                              for a13
col sql_child_number    head CH#        for 999
col SQL_PROFILE         head PROFILE    for a19
col time_start          for a24
col time_end            for a24
col module              for a18
col action              for a18
col parsing_schema_name for a18
col elaexe              for a13
col elacpu              for a13
col ela_io              for a13
col ela_app             for a13
col ela_pls             for a13
col all_elaexe          for a13

col ROWS_PROCESSED_D    for a13
col DIRECT_WRITES_D     for a13
col PH_READ_REQS_D      for a13
col PH_READ_BYTES_D     for a13
col PH_WRITE_REQS_D     for a13
col PH_WRITE_BYTES_D    for a13

col buf_gets_per_exec   for a15
col disk_reads_per_exec for a15


with t as (
select/*+ SQLSTAT */
        st.snap_id
       ,snaps.begin_interval_time time_start
       ,snaps.end_interval_time time_end
       ,st.dbid
       ,st.plan_hash_value
       ,to_char(decode(st.executions_delta,0,0,st.elapsed_time_delta / 1e6 / st.executions_delta),'9999.99990')  as elaexe
       ,to_char(decode(st.executions_delta,0,0,st.cpu_time_delta     / 1e6 / st.executions_delta),'9999.99990')  as elacpu
       ,to_char(decode(st.executions_delta,0,0,st.iowait_delta       / 1e6 / st.executions_delta),'9999.99990')  as ela_io
       ,to_char(decode(st.executions_delta,0,0,st.apwait_delta       / 1e6 / st.executions_delta),'9999.99990')  as ela_app
       ,to_char(decode(st.executions_delta,0,0,st.PLSEXEC_TIME_DELTA / 1e6 / st.executions_delta),'9999.99990')  as ela_pls
       ,to_char(decode(st.executions_total,0,0,st.elapsed_time_total / 1e6 / st.executions_total),'9999.99990')  as all_elaexe
       ,st.executions_delta                                                                                      as cnt 
       ,st.executions_total                                                                                      as all_cnt
       ,to_char(decode(st.executions_delta,0,0,st.buffer_gets_delta / st.executions_delta ),'99g999g999d90',q'[nls_numeric_characters='.`']') buf_gets_per_exec
       ,to_char(decode(st.executions_delta,0,0,st.disk_reads_delta / st.executions_delta ),'999999.90')          as disk_reads_per_exec
       ,st.module
       ,st.action
       ,st.sql_profile
       ,st.parsing_schema_name
       ,to_char(decode(st.executions_delta,0,0,st.fetches_delta                 /  st.executions_delta),'9999.0')  as fetches_delta
       ,st.end_of_fetch_count_delta eofetch_delta
       ,st.invalidations_delta
       ,st.parse_calls_delta
       ,to_char(decode(st.executions_delta,0,0,st.ROWS_PROCESSED_DELTA          /  st.executions_delta),'999999.0')  as ROWS_PROCESSED_D
       ,to_char(decode(st.executions_delta,0,0,st.DIRECT_WRITES_DELTA           /  st.executions_delta),'999999.0')  as DIRECT_WRITES_D
       ,to_char(decode(st.executions_delta,0,0,st.PHYSICAL_READ_REQUESTS_DELTA  /  st.executions_delta),'999999.0')  as PH_READ_REQS_D
       ,to_char(decode(st.executions_delta,0,0,st.PHYSICAL_READ_BYTES_DELTA     /  st.executions_delta),'999999.0')  as PH_READ_BYTES_D
       ,to_char(decode(st.executions_delta,0,0,st.PHYSICAL_WRITE_REQUESTS_DELTA /  st.executions_delta),'999999.0')  as PH_WRITE_REQS_D
       ,to_char(decode(st.executions_delta,0,0,st.PHYSICAL_WRITE_BYTES_DELTA    /  st.executions_delta),'999999.0')  as PH_WRITE_BYTES_D

from v$database db
    ,dba_hist_sqlstat st
    ,dba_hist_snapshot snaps
where 
      st.sql_id  = '&1'
  and st.dbid    = db.dbid
  and st.snap_id = snaps.snap_id
  and st.executions_delta>0
order by 1 desc
)
select *
from t
where rownum<=&_ROWNUM;

col time_start          clear
col time_end            clear
col module              clear
col action              clear
col parsing_schema_name clear
col elaexe              clear
col elacpu              clear
col ela_io              clear
col ela_app             clear
col ela_pls             clear
col all_elaexe          clear
col ROWS_PROCESSED_D    clear
col DIRECT_WRITES_D     clear
col PH_READ_REQS_D      clear
col PH_READ_BYTES_D     clear
col PH_WRITE_REQS_D     clear
col PH_WRITE_BYTES_D    clear

col buf_gets_per_exec   clear
col disk_reads_per_exec clear

@inc/input_vars_undef;