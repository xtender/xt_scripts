@inc/input_vars_init

col owner             for a30
col table_name        for a30
col constraint_name   for a30
col cols              for a60
col index_ddl         for a120;

prompt &_C_REVERSE *** Unindexed foreign keys. Specify "create" to print ddl. &_C_RESET
prompt &_C_RED Usage: @unindexed_in_table table_mask [owner_mask] [create] &_C_RESET

col _default    new_value _default noprint;
col _create     new_value _create noprint;
select 
      case when lower('&2') ='create' or lower('&3') ='create'
               then '--'
            else ''
      end "_default"
   ,  case when lower('&2') ='create' or lower('&3') ='create'
               then null
            else '--'
      end "_create"
from dual;
col _create clear;
col x noprint
with 
 tabs as (
      select t.owner,t.table_name 
      from dba_tables t 
      where t.owner like upper(nvl('&2','%')) 
        and t.table_name like upper('&1')
)
,t_cons_cols as (
      select
         c.owner
        ,c.table_name
        ,c.constraint_name
        ,c.LAST_CHANGE
        ,(select listagg(cc.column_name,',')within group(order by cc.position) 
          from dba_cons_columns cc
          where
              cc.table_name      = c.table_name
          and cc.owner           = c.owner
          and cc.constraint_name = c.constraint_name
         ) as cols
      from 
         tabs
        ,dba_constraints c
      where tabs.owner         = c.owner
        and tabs.table_name    = c.table_name
        and c.constraint_type  = 'R'
        and c.status           = 'ENABLED'
)
,t_ind_cols as (
      select
         ic.table_owner owner
        ,ic.table_name  table_name
        ,listagg(ic.column_name,',')within group(order by ic.column_position) i_cols
      from tabs
          ,dba_ind_columns ic
      where tabs.owner      = ic.table_owner
        and tabs.table_name = ic.table_name
      group by ic.table_owner,ic.table_name,ic.index_name
 )
select
   distinct ' ' x
&&_default     ,cc.owner
&&_default     ,cc.table_name
&&_default     ,cc.constraint_name
&&_default     ,cc.cols
&&_default     ,cc.LAST_CHANGE
&&_create      ,'create index '
&&_create           ||owner||'.'
&&_create           ||rpad('ix_'||table_name||'_'||replace(cols,',','_'),30)
&&_create     ||' on '||owner||'.'||table_name||'('||cols||');' as index_ddl
from t_cons_cols cc
where 
    cc.cols not in (
        select
           i_cols
        from t_ind_cols
        where 
              t_ind_cols.owner      = cc.owner
          and t_ind_cols.table_name = cc.table_name
    )
/
col x                 clear;
col owner             clear;
col table_name        clear;
col constraint_name   clear;
col cols              clear;
col index_ddl         clear;
@inc/input_vars_undef