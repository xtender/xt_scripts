@inc/input_vars_init.sql;
set termout off
COL _if_projection NEW_VALUE _if_projection NOPRINT
COL _if_predicates NEW_VALUE _if_predicates NOPRINT
select case when '&2 &3 &4 &5' like '%+proj%' then '  ' else '--' end "_if_projection"
      ,case when '&2 &3 &4 &5' like '%+pred%' then '  ' else '--' end "_if_predicates"
from dual;
set termout on
------------------------------------------------------------------------------------------------------------------------
--
-- File name:   asqlmon.sql (v1.0)
--
-- Purpose:     Report SQL-monitoring-style drill-down into where in an execution plan the execution time is spent
--
-- Author:      Tanel Poder
--
-- Copyright:   (c) http://blog.tanelpoder.com - All rights reserved.
--
-- Disclaimer:  This script is provided "as is", no warranties nor guarantees are
--              made. Use at your own risk :)
--              
-- Usage:       @asqlmon <sqlid> <child#>
--
-- Notes:       This script runs on Oracle 11g+ and you should have the
--              Diagnostics and Tuning pack licenses for using it as it queries
--              some separately licensed views.
--
------------------------------------------------------------------------------------------------------------------------

COL asqlmon_operation                   FOR a80
COL asqlmon_predicates                  FOR a100 word_wrap
COL options                             FOR a30

COL asqlmon_plan_hash_value             HEAD PLAN_HASH_VALUE
COL asqlmon_sql_id                      HEAD SQL_ID  NOPRINT
COL asqlmon_sql_child                   HEAD CHILD#  
COL asqlmon_sample_time                 HEAD SAMPLE_HOUR
COL obj_alias_qbc_name                  for a30
COL event                               FOR A50
COL projection                          FOR A150

COL pct_child HEAD "Activity %"         FOR A8
COL pct_child_vis HEAD "Visual"         FOR A12

COL asqlmon_id        HEAD "Line ID"    FOR 9999
COL asqlmon_parent_id HEAD "Parent"     FOR 9999


rem BREAK ON asqlmon_plan_hash_value SKIP 1 ON asqlmon_sql_id SKIP 1 ON asqlmon_sql_child SKIP 1 ON asqlmon_sample_time SKIP 1 DUP ON asqlmon_operation
BREAK ON asqlmon_sql_id SKIP 1 ON snap_id SKIP 1 ON asqlmon_plan_hash_value SKIP 1 ON secs_by_plan_line SKIP 1 DUP

WITH  
  snaps as (
           select distinct st.dbid, st.snap_id, st.instance_number,st.sql_id,st.plan_hash_value
           from dba_hist_sqlstat st
           where st.sql_id='&1'
             and st.plan_hash_value like '%&2%'
           )
 ,sq AS (
                  SELECT
                    --  to_char(ash.sample_time, 'YYYY-MM-DD HH24') sample_time
                      count(*) samples
                    , sum(count(*)) over(partition by ash.sql_id,ash.snap_id,ash.sql_plan_line_id) samples_by_line
                    , ash.sql_id
                    , ash.snap_id
                    , ash.sql_plan_hash_value
                    , ash.sql_plan_line_id
                    , ash.sql_plan_operation
                    , ash.sql_plan_options
                    , ash.session_state
                    , ash.event
                  FROM
                      snaps s
                      ,dba_hist_active_sess_history ash
                  WHERE
                      1=1
                  AND s.dbid            = ash.dbid
                  and s.snap_id         = ash.snap_id
                  and s.instance_number = ash.instance_number
                  and s.sql_id          = ash.sql_id
                  AND s.plan_hash_value = ash.sql_plan_hash_value
                  --AND ash.session_id = 8 AND ash.session_serial# =     35019
                  GROUP BY
                    --to_char(ash.sample_time, 'YYYY-MM-DD HH24')
                      ash.sql_id
                    , ash.snap_id
                    , ash.sql_plan_hash_value
                    , ash.sql_plan_line_id
                    , ash.sql_plan_operation
                    , ash.sql_plan_options
                    , ash.session_state
                    , ash.event
  )
SELECT
                    plan.sql_id             as asqlmon_sql_id
                  , plan.plan_hash_value    as asqlmon_plan_hash_value
                  , sq.snap_id
                  , sq.samples_by_line      as secs_by_plan_line
                  , sq.samples              as seconds
                  , LPAD(TO_CHAR(ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 100, 1), 999.9)||' %',8) as pct_child
                  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 10), '#'), ' '), 10,' ')||'|' as pct_child_vis
                  --, sq.sample_time         asqlmon_sample_time
                  --, LPAD(plan.id,4)||CASE WHEN parent_id IS NULL THEN '    ' ELSE ' <- ' END||LPAD(plan.parent_id,4) asqlmon_plan_id
                  , plan.id                 as asqlmon_id
                  , plan.parent_id          as asqlmon_parent_id
                  , LPAD(' ', depth) || plan.operation ||' '|| plan.options || NVL2(plan.object_name, ' ['||plan.object_name ||']', null) as asqlmon_operation
                  , sq.session_state
                  , sq.event
                  , plan.object_alias || CASE WHEN plan.qblock_name IS NOT NULL THEN ' ['|| plan.qblock_name || ']' END as obj_alias_qbc_name
&_if_predicates   ,    CASE WHEN plan.access_predicates IS NOT NULL THEN ' [A:] '|| plan.access_predicates END 
&_if_predicates     || CASE WHEN plan.filter_predicates IS NOT NULL THEN ' [F:]' || plan.filter_predicates END   as asqlmon_predicates
&_if_projection   , plan.projection
                FROM
                    dba_hist_sql_plan plan
                  , sq
                WHERE
                    1=1
                AND sq.sql_id(+)              = plan.sql_id
                AND sq.sql_plan_line_id(+)    = plan.id
                AND sq.sql_plan_hash_value(+) = plan.plan_hash_value
                AND plan.sql_id               = '&1'
                and plan.plan_hash_value  like '%&2%'
                ORDER BY
                  --sq.sample_time
                    sq.snap_id
                  , plan.plan_hash_value
                  , plan.id
                  , sq.samples desc
/
clear BREAKs
@inc/input_vars_undef.sql;