@inc/input_vars_init.sql
col owner   format a12
col cols    format a50
col r_cols  format a50

with 
 t_cons_cols as (
      select--+ no_merge OPT_PARAM('optimizer_index_caching' 90) OPT_PARAM('optimizer_index_cost_adj' 1)
         c.owner
        ,c.table_name
        ,c.constraint_name
        ,c.last_change
        ,decode(c.status,'ENABLED','V','DISABLED','-','?') STATE
        ,c.constraint_type
        ,decode( c.constraint_type
                ,'R',(select max(rc.owner||'.'||rc.table_name)
                             ||'('
                             ||listagg(rc.column_name,',')within group(order by rc.position)
                             ||')' 
                      from dba_cons_columns rc 
                      where rc.owner=c.r_owner 
                      and rc.constraint_name=c.r_constraint_name
                     )
               ) r_cols
        ,listagg(cc.column_name,',')within group(order by cc.position) cols
      from dba_constraints c
          ,dba_cons_columns cc
      where c.owner like nvl(upper('&1'),'%')
        and c.table_name like upper('&2')
        --and c.status          = 'ENABLED'
        and cc.owner           = c.owner
        and cc.table_name      = c.table_name
        and cc.constraint_name = c.constraint_name
      group by c.owner,c.table_name,c.constraint_name,c.constraint_type,c.last_change,c.status,c.r_owner,c.r_constraint_name
)
,t_ind_cols as (
      select--+ 
         ic.table_owner owner
        ,ic.table_name  table_name
        ,listagg(ic.column_name,',')within group(order by ic.column_position) i_cols
      from dba_ind_columns ic
--      where ic.index_owner like upper('&1')
--        and ic.table_owner like upper('&1')
--        and ic.table_name  like upper('&2')
      group by ic.table_owner,ic.table_name,ic.index_name
 )
select 
  cc.*
 ,case when not exists(select null from t_ind_cols tic where tic.owner=cc.owner and tic.table_name=cc.table_name and instr(tic.i_cols,cc.cols)=1)
            --cc.cols not in ( select i_cols from t_ind_cols ) 
            then 'Not indexed'
       else '***'
  end  indexing
from t_cons_cols cc
/
col cols    clear
col r_cols  clear
@inc/input_vars_undef.sql