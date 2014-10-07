prompt ASH by sid and serial# grouped by sql_id,event:
prompt ===============================================
accept _sid     prompt "SID: ";
accept _serial  prompt "Serial: ";

col DT_START    format a25;
col DT_END      format a25;
col SQL_ID      format a13;
col EVENT       format a64;


select 
   grp
  ,min(sample_time) dt_start
  ,max(sample_time) dt_end
  ,min(sample_id)   id_start
  ,max(sample_id)   id_end
  ,sql_id
  ,event
  ,count(*) cnt
from(
   select
     sql_id
    ,event
    ,sample_id
    ,sample_time
    ,sum(flg) over(order by sample_id) grp
   from (
         select 
             h.sql_id
            ,h.event
            ,h.sample_time
            ,h.SAMPLE_ID
            ,case 
                when h.sample_id - 1 = lag(h.sample_id) over(order by h.sample_id) 
                 and h.sql_id        = lag(h.sql_id)    over(order by h.sample_id)
                 and h.event         = lag(h.event)     over(order by h.sample_id)
                   then 0 
                else 1 
             end flg
         from v$active_session_history h
         where h.session_id      = &_sid 
           and h.session_serial# = &_serial
        )
)
group by grp,sql_id,event
order by grp;

undef _sid;
undef _serial;

col DT_START    clear;
col DT_END      clear;
col SQL_ID      clear;
col EVENT       clear;
