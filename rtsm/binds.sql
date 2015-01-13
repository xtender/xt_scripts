@inc/input_vars_init;
PROMPT *            &_C_RED *** Binds values from Real-Time SQL Monitor *** &_C_RESET;
PROMPT * Usage @rtsm/binds sql_id [sql_exec_id] [status_mask]

col USERNAME    format a25;
col status      format a15;
col binds       format a120;
col m_elaexe    format a12;
with agg as (
      select distinct
             sm.username,sm.sid,sm.session_serial# serial#
            , to_char(trunc(ELAPSED_TIME/1e6/60))
             ||':'||
             to_char(mod(ELAPSED_TIME,60e6)/1e6,'fm00.000')  as m_elaexe
            ,sm.sql_exec_id exec_id,sm.SQL_EXEC_START exec_start,sm.SQL_PLAN_HASH_VALUE plan_hv
            ,dat.name  
            ,dat.pos   
            ,dat.dtystr
            ,dat.maxlen
            ,dat.len   
            ,nvl(dat.val,'NULL') val
      from v$sql_monitor sm
          ,xmltable( '/data/binds/bind'
                     passing xmltype('<data>'||sm.binds_xml||'</data>')
                     columns 
                         name     varchar2(30) path '@name'
                        ,pos      int          path '@pos'
                        ,dtystr   varchar2(15) path '@dtystr'
                        ,maxlen   int          path '@maxlen'
                        ,len      int          path '@len'
                        ,val      varchar2(30) path '.'
          ) dat
      where 
          sm.status like nvl('&3','EXECUTING')
      and sm.sql_id='&1'
      and sm.sql_exec_id like case when regexp_like('&2','\d+') then '&2' else '%' end
)
select username
      ,sid
      ,serial#
      ,exec_id
      ,exec_start
      ,plan_hv
      ,m_elaexe
      ,listagg(agg.name||'('||agg.dtystr||')='||agg.val,', ') within group(order by agg.pos)binds
from agg
group by username,sid,serial#,exec_id,exec_start,plan_hv,m_elaexe
order by exec_start
/
col USERNAME    clear
col status      clear
col binds       clear
col m_elaexe    clear
@inc/input_vars_undef;