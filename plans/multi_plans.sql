col sql_text for a80
pro ******************************************************************************************************
pro *** This script searchs the shared pool for SQL stataments with How_Many (or more) distinct plans. ***
pro ******************************************************************************************************
--set termout off
select sql_id,  count(distinct plan_hash_value) distinct_plans, sql_text
from v$sql
group by sql_id, sql_text
having count(distinct plan_hash_value) >= &how_many
/
