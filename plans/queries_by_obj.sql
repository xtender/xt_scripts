@inc/input_vars_init;
col username format a13
col prog format a22
col sql_text format a41
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

with sqlids as (
     select distinct
         gp.inst_id
        ,gp.sql_id 
        ,gp.plan_hash_value
        ,gp.child_number
     from gv$sql_plan gp
     where gp.OBJECT_NAME  like upper('%&1%')
       and gp.OBJECT_OWNER like upper('%&2%')
), stats as (
    select 
        i.sql_id
       ,i.child_number
       ,i.plan_hash_value plan_hv
       ,executions execs
       ,elapsed_time/1e6  etime
       ,(elapsed_time/1e6)/decode(nvl(executions,0),0,1,executions) avg_etime
       ,u.username
       ,sql_text
    from sqlids i
        ,gv$sql s
        ,dba_users u
    where 
           s.sql_id = i.sql_id
       and u.user_id = s.parsing_user_id
       and s.plan_hash_value = i.plan_hash_value
    order by etime desc,execs desc
)
select *
from stats
where rownum<=15
/
@inc/input_vars_undef;
