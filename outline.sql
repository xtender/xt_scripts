@inc/input_vars_init.sql

col hint format a180;
break on sql_id on plan_hash_value on child_number on cnt

with t as (
   select sql_id,plan_hash_value,s.child_number, count(*) cnt
   from v$sql s
   where sql_id='&1'
     and child_number like nvl('&2','%')
   group by sql_id,plan_hash_value,s.child_number
   order by sql_id,s.child_number,s.plan_hash_value
)
select
    t.sql_id
   ,t.plan_hash_value
   ,t.cnt
   ,t.child_number
   ,',q''['||d.hint||']''' hint
from
  t,
  xmltable('/other_xml/outline_data/*'
      passing (
          select
              xmltype(other_xml) as xmlval
          from
              v$sql_plan sp
          where
                  sp.sql_id          = t.sql_id
              and sp.plan_hash_value = t.plan_hash_value
              and sp.other_xml is not null
              and sp.id=1
      )
      columns
      "HINT" varchar2(4000) PATH '/hint'
) d;

col hint clear
clear break