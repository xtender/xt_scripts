@inc/input_vars_init;
PROMPT *            &_C_RED *** Binds values from Real-Time SQL Monitor *** &_C_RESET;
PROMPT * Usage @rtsm/binds sql_id [sql_exec_id] [status_mask]

col USERNAME    format a25;
col status      format a15;
col binds       format a120;
col m_elaexe    format a12;

col name        for a10;
col dtystr      for a12 trunc;
col val         for a300 word;
break on username on sid on serial# on exec_id on exec_start on plan_hv on m_elaexe skip 1;

with agg as (
      select distinct
             sm.username,sm.sid,sm.session_serial# serial#
            , to_char(trunc(ELAPSED_TIME/1e6/60))
             ||':'||
             to_char(mod(ELAPSED_TIME,60e6)/1e6,'fm00.000')  as m_elaexe
            ,sm.sql_exec_id exec_id,sm.SQL_EXEC_START exec_start,sm.SQL_PLAN_HASH_VALUE plan_hv
            ,dat.name  
            --,dat.pos   
            ,dat.dtystr
            ,dat.maxlen
            ,dat.len   
            ,nvl(dat.val,'NULL') val
      from ( select sm.*
                   ,row_number()over(order by decode(sm.status,'EXECUTING',1,2), SQL_EXEC_START desc) rn
             from v$sql_monitor sm
             where sm.status like nvl('&3','EXECUTING')
               and sm.sql_id='&1'
               and sm.sql_exec_id like case when regexp_like('&2','\d+') then '&2' else '%' end
             
           ) sm
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
          sm.rn<=10
)
select username
      ,sid
      ,serial#
      ,exec_id
      ,exec_start
      ,plan_hv
      ,m_elaexe
      --,listagg(agg.name||'('||agg.dtystr||')='||agg.val,chr(10)) within group(order by agg.name)binds
      ,agg.name
      ,agg.dtystr
      ,agg.val
from agg
--group by username,sid,serial#,exec_id,exec_start,plan_hv,m_elaexe
order by exec_start,exec_id
/
clear break;
col USERNAME    clear
col status      clear
col binds       clear
col m_elaexe    clear

col name        clear
col dtystr      clear
col val         clear

@inc/input_vars_undef;