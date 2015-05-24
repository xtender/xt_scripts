col object_name format a30
col object_type format a12
col event       format a40;
break on snap_id skip 1 on cnt_by_snap skip 1 on sql_id skip 1 on sql_child skip 1 on plan_hv skip 1 on obj on object_type on object_name on cnt_by_obj skip 1

with 
   snaps as (
           select distinct st.dbid, st.snap_id, st.instance_number,st.sql_id,st.plan_hash_value
           from dba_hist_sqlstat st
           where st.sql_id='&1'
           )
 , sq AS (
                  SELECT
                      ash.sql_id
                    , ash.sql_child_number
                    , ash.sql_plan_hash_value   plan_hv
                    , ash.CURRENT_OBJ#          obj
                    , count(*) cnt
                    , sum(count(*)) 
                         over(partition by 
                                       sql_plan_hash_value
                                      ,current_obj#
                                      ,sql_child_number
                             ) cnt_by_obj
                    , ash.session_state
                    , ash.event
                  from snaps s
                      ,dba_hist_active_sess_history ash
                  where s.dbid            = ash.dbid
                    and s.snap_id         = ash.snap_id
                    and s.instance_number = ash.instance_number
                    and s.sql_id          = ash.sql_id
                    AND s.plan_hash_value = ash.sql_plan_hash_value
                  GROUP BY
                      ash.sql_id
                    , ash.sql_child_number
                    , ash.sql_plan_hash_value
                    , ash.session_state
                    , ash.event
                    , ash.CURRENT_OBJ#
)
SELECT
                sq.sql_id
              , sq.sql_child_number sql_child
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
      cnt_by_obj  desc
     ,cnt         desc
/
clear BREAKs
col object_name clear;
col object_type clear;
col event       clear;
