col wait_class          format a20;
col name                format a35;
col period              format a17;
col avg_wait_time       format 90.000000;
col avg_fg_wait_time    format 90.000000;
with v as (
   select
       row_number()over(order by time_waited+time_waited_fg desc) rn
      ,n.wait_class
      ,n.name
      ,m.BEGIN_TIME
      ,m.END_TIME
      ,to_char(m.BEGIN_TIME,'hh24:mi:ss')||'-'||to_char(m.END_TIME,'hh24:mi:ss')    as period
      ,m.INTSIZE_CSEC                                                               as csec
      ,m.NUM_SESS_WAITING                                                           as SESS_WAITING
      ,m.TIME_WAITED
      ,m.WAIT_COUNT
      ,decode(WAIT_COUNT,0,0,TIME_WAITED/WAIT_COUNT/100)                            as avg_wait_time
&_IF_ORA11_OR_HIGHER      ,m.TIME_WAITED_FG
&_IF_ORA11_OR_HIGHER      ,m.WAIT_COUNT_FG
&_IF_ORA11_OR_HIGHER      ,decode(WAIT_COUNT_FG,0,0,TIME_WAITED_FG/WAIT_COUNT_FG/100)  as avg_fg_wait_time
   from v$eventmetric m,v$event_name n
   where m.event#=n.EVENT#
     and wait_class not in ('Idle')
     and time_waited+time_waited_fg>0
)
select 
                        rn
                       ,wait_class
                       ,name
                       ,period
                       ,csec
                       ,SESS_WAITING
                       ,TIME_WAITED
                       ,WAIT_COUNT
                       ,avg_wait_time   
&_IF_ORA11_OR_HIGHER   ,TIME_WAITED_FG
&_IF_ORA11_OR_HIGHER   ,WAIT_COUNT_FG
&_IF_ORA11_OR_HIGHER   ,avg_fg_wait_time
from v
where rn<=10
order by rn
/
col wait_class          clear;
col name                clear;
col period              clear;
col avg_wait_time       clear;
col avg_fg_wait_time    clear;
