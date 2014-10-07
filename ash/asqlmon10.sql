@inc/input_vars_init.sql;
set termout off
COL _if_child NEW_VALUE _IF_CHILD NOPRINT
select case when '&2 &3 &4 &5' like '%+child%' then '  ' else '--' end "_if_child"
from dual;
set termout on
col object_name format a30
col object_type format a12
col event       format a40;
break on sql_id skip 1 on sql_child skip 1 on plan_hv skip 1 on obj on object_type on object_name on cnt_by_obj skip 1

WITH  
   sq AS (
                  SELECT
                      ash.sql_id
&&_IF_CHILD         , ash.sql_child_number
                    , ash.sql_plan_hash_value   plan_hv
                    , ash.CURRENT_OBJ#          obj
                    , count(*) cnt
                    , sum(count(*)) 
                         over(partition by 
                                       sql_plan_hash_value
                                      ,current_obj#
&&_IF_CHILD                           ,sql_child_number
                             ) cnt_by_obj
                    , ash.session_state
                    , ash.event
                  FROM
                      gv$active_session_history ash
                  WHERE 1=1
                  AND ash.sql_id LIKE '&1'
                  AND ash.SQL_PLAN_HASH_VALUE like '%&2%'
                  GROUP BY
                      ash.sql_id
&&_IF_CHILD         , ash.sql_child_number
                    , ash.sql_plan_hash_value
                    , ash.session_state
                    , ash.event
                    , ash.CURRENT_OBJ#
)
SELECT
                sq.sql_id
&&_IF_CHILD   , sq.sql_child_number sql_child
              , sq.plan_hv
              , sq.obj
              , o.object_type
              , o.object_name
              , sq.cnt_by_obj
              , sq.session_state
              , sq.event
              , sq.cnt
FROM
    sq
  , dba_objects o
WHERE 1=1
and o.object_id=sq.obj
order by 
      cnt_by_obj desc
     ,cnt desc
/
clear BREAKs
col object_name clear;
col object_type clear;
col event       clear;
@inc/input_vars_undef.sql;