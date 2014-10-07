prompt &_C_REVERSE *** Fast distinct column values for column with small number values and this column is the first column in some index &_C_RESET
accept tab prompt "Table : ";
accept col prompt "Column: ";

with 
  v_distinct(val) as (
     select min(&col) from &tab
     union all
     select (select min(&col) from &tab t2 where t2.&col>v_distinct.val)
     from v_distinct
     where val is not null
  )
select
  *
from v_distinct 
where val is not null
/