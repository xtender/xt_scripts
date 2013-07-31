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
                             ||' ('
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
      where 
            c.last_change      > date'&1'
        and c.constraint_type  = 'R'
        and c.status           = 'ENABLED'
        and c.owner            like '&2'
        and cc.owner           = c.owner
        and cc.table_name      = c.table_name
        and cc.constraint_name = c.constraint_name
      group by c.owner,c.table_name,c.constraint_name,c.constraint_type,c.last_change,c.status,c.r_owner,c.r_constraint_name
)
,t_ind_cols as (
      select 
         ic.table_owner owner
        ,ic.table_name  table_name
        ,listagg(ic.column_name,',')within group(order by ic.column_position) i_cols
      from dba_ind_columns ic
      group by ic.table_owner,ic.table_name,ic.index_name
 )
,t_checked as (
      select 
        cc.*
        ,max(length(owner))     over()                              ml_owner
        ,max(length(table_name))over()                              ml_tab_name
        ,max(length(cols ))over()                                   ml_cols
        ,substr('IX_'||table_name||'_'||cols ,1,30)                 index_name
      from t_cons_cols cc
      where not exists(select null from t_ind_cols tic where tic.owner=cc.owner and tic.table_name=cc.table_name and instr(tic.i_cols,cc.cols)=1)
)
select 
    owner
   ,table_name
   ,constraint_name
   ,last_change
   ,state
   ,r_cols
   ,cols
   ,'create index '||lpad(owner,ml_owner)
                   ||'.'
                   ||rpad(index_name,max(length(index_name))over())
                   ||' on '||lpad(owner,ml_owner)||'.'||rpad(table_name,ml_tab_name)
                   ||'('||rpad(cols,ml_cols)||')'
                   ||' tablespace ix_users online;' as indexing
from t_checked
where 1=1
/