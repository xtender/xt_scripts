@inc/input_vars_init.sql;
col USERNAME    format a25
col name        format a15
col val         format a70
col status      format a15
col dtystr      format a15

select m.USERNAME
      ,m.SQL_EXEC_ID
      ,m.SQL_PLAN_HASH_VALUE plan_hv
      ,m.SQL_EXEC_START 
      ,m.STATUS
      ,x.*
from v$sql_monitor m
    ,xmltable(
              '/binds/*'
              passing xmltype(m.BINDS_XML)
              columns 
                name      varchar2(20)   path '@name'
               ,pos       int            path '@pos'
               ,dty       int            path '@dty'
               ,dtystr    varchar2(20)   path '@dtystr'
               ,maxlen    int            path '@maxlen'
               ,csid      int            path '@csid'
               ,len       int            path '@len'
               ,val       varchar2(4000) path 'text()'
    )(+) x
where 
      m.sql_id = '&1'
  and m.SQL_EXEC_ID like nvl('&2','%')
  and m.SQL_EXEC_START>=sysdate - decode((&3 + 0),0,15, &3 + 0)/24/60
order by 1,2,3,4,5,7
/
@inc/input_vars_undef.sql;