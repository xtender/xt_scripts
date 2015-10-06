prompt ********************************************************
prompt &_C_RED * Find FK related to the table &1 &_C_RESET;
prompt *** Usage: @fk_to_table table_name [owner]

@inc/input_vars_init;

col r_owner for a30;
col r_cons  for a30;
col r_type  for a4;
col r_table for a30;
col owner   for a30;
col constraint_name for a30;
col table_name for a30;

prompt &_C_RED **************************************************** &_C_RESET
prompt * FK &_C_YELLOW&_C_BOLD IN &_C_RESET the table &1: 

select 
     cc.owner             as r_owner
    ,cc.table_name        as r_table
    ,cc.constraint_name   as r_cons
    ,cc.constraint_type   as r_type
    ,cc.r_constraint_name as r_cons
    ,rc.table_name        as r_table
from dba_constraints cc 
    ,dba_constraints rc
where cc.owner            like upper(nvl('&2','%'))
  and cc.table_name       like upper('&1')
  and cc.r_owner           = rc.owner
  and cc.r_constraint_name = rc.constraint_name
/
prompt &_C_RED **************************************************** &_C_RESET
prompt * FK &_C_YELLOW&_C_BOLD TO ==>&_C_RESET &1: 

with
   r_cons as (
              select 
                 cc.owner            as r_owner
                ,cc.constraint_name  as r_cons
                ,cc.constraint_type  as r_type
                ,cc.table_name       as r_table
              from dba_constraints cc 
              where cc.owner      like upper(nvl('&2','%'))
                and cc.table_name like upper('&1')
                and cc.constraint_type not in ('C','R')
             )
select 
   r_cons.r_owner
  ,r_cons.r_table
  ,r_cons.r_cons
  ,r_cons.r_type
  ,c.owner
  ,c.constraint_name
  ,c.table_name
from r_cons, dba_constraints c 
where r_cons.r_owner = c.r_owner (+)
  and r_cons.r_cons  = c.r_constraint_name(+)
/
col r_owner clear;
col r_cons  clear;
col r_type  clear;
col r_table clear;
col owner   clear;
col constraint_name clear;
col table_name clear;
@inc/input_vars_undef
