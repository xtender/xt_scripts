@inc/input_vars_init

col owner             for a30
col table_name        for a30
col constraint_name   for a30
col cols              for a60

doc 
Example: @unindex_in_table owner_mask table_mask
#

with 
 t_cons_cols as (
      select--+ inline
         c.owner
        ,c.table_name
        ,c.constraint_name
        ,listagg(cc.column_name,',')within group(order by cc.position) cols
      from dba_constraints c
           join dba_cons_columns cc
                on cc.table_name       = c.table_name
                and cc.owner           = c.owner
                and cc.constraint_name = c.constraint_name
      where c.constraint_type = 'R'
        and c.status          = 'ENABLED'
      group by c.owner,c.table_name,c.constraint_name
)
,t_ind_cols as (
      select--+ inline
         ic.table_owner owner
        ,ic.table_name  table_name
        ,listagg(ic.column_name,',')within group(order by ic.column_position) i_cols
      from dba_ind_columns ic
      group by ic.table_owner,ic.table_name,ic.index_name
 )
select/*+ merge(cc) */ 
   cc.owner
  ,cc.table_name
  ,cc.constraint_name
  ,cc.cols
from t_cons_cols cc
where 
    cc.owner          like nvl('&2','%')
    and cc.table_name = upper('&1')
    and cc.cols not in (
        select/*+ merge(t_ind_cols) */ i_cols
        from t_ind_cols
        where 
              t_ind_cols.owner      = cc.owner
          and t_ind_cols.table_name = cc.table_name
    )
/
col owner             clear
col table_name        clear
col constraint_name   clear
col cols              clear
@inc/input_vars_undef