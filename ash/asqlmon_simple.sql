@inc/input_vars_init
COL operation FOR a30
COL options   FOR a30


WITH  sample_times AS (
    select * from dual
), 
sq AS (
SELECT
    to_char(ash.sample_time, 'YYYY-MM-DD HH24') sample_time
  , count(*) samples
  , ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
FROM
    v$active_session_history ash
WHERE
    1=1
AND ash.sql_id = '&1'
AND ash.sql_child_number LIKE '%&2%'
and ash.SQL_PLAN_HASH_VALUE like '%&3%'
GROUP BY
    to_char(ash.sample_time, 'YYYY-MM-DD HH24')
  , ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
)
SELECT
    sq.samples
  , plan.sql_id
  , plan.child_number
  , sq.sample_time
  , plan.id 
  , plan.operation
  , plan.options
FROM
    v$sql_plan plan
  , sq
WHERE
    1=1
AND sq.sql_id(+) = plan.sql_id
AND sq.sql_child_number(+) = plan.child_number
AND sq.sql_plan_line_id(+) = plan.id
AND plan.sql_id = '&1'
AND plan.child_number LIKE '%&2%'
ORDER BY
   -- sq.sample_time
    to_number(plan.id)
/
@inc/input_vars_undef