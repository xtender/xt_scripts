@inc/input_vars_init;

col tab           format a40;
col name          format a30;
col cols          format a40;
col conditions    format a40;
col delete_rule   format a8;
col r_constraint  format a40;
col index_owner   format a30;
col index_name    format a30;
col status        format a10;

select 
     c.owner||'.'||c.table_name      as tab
    ,c.constraint_name               as name
    ,c.constraint_type               as type
    ,(select 
        xmlquery('string-join(.,",")'
                 passing  xmlagg(xmlelement(COL,cc.column_name) order by cc.position)
                 returning content
                ).getstringval() xx
      from dba_cons_columns cc 
      where c.owner = cc.owner 
        and c.constraint_name = cc.constraint_name
     )                               as cols
    ,c.search_condition              as conditions
    ,nvl2(c.r_owner,c.r_owner||'.'||c.r_constraint_name,'') as r_constraint
    ,c.delete_rule
    ,c.status
    ,c.last_change
    ,nvl2(c.index_owner,c.index_owner||'.'||c.index_name,'') as index_name
    ,c.deferrable
    ,c.deferred
    ,c.validated
    ,c.generated
    ,c.bad
    ,c.rely
    ,c.invalid
    ,c.view_related
from dba_constraints c
where c.owner like upper(nvl('&2','%'))
  and c.table_name like upper('&1')
/
col tab           clear;
col name          clear;
col cols          clear;
col conditions    clear;
col delete_rule   clear;
col r_constraint  clear;
col index_owner   clear;
col index_name    clear;
col status        clear;
