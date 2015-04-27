col beg_time for a13;
col end_time for a13;
col db_time       format 9990d00;
col cpu           format 9990d00;
col bg_db_time    format 9990d00;
col bg_cpu        format 9990d00;
col host_cpu      format 9990d00;

select to_char(begin_time,'hh24:mi:ss')                                  as beg_time
      ,to_char(  end_time,'hh24:mi:ss')                                  as end_time
      ,sum(decode(metric_name,'Database Time Per Sec'        ,value))/60 as db_time
      ,sum(decode(metric_name,'CPU Usage Per Sec'            ,value))/60 as cpu
      ,sum(decode(metric_name,'Background Time Per Sec'      ,value))/60 as BG_db_time
      ,sum(decode(metric_name,'Background CPU Usage Per Sec' ,value))/60 as BG_cpu
      ,sum(decode(metric_name,'Host CPU Usage Per Sec'       ,value))/60 as host_cpu
from v$sysmetric_history h
where 1=1
and h.INTSIZE_CSEC > 3000
and end_time> sysdate - interval '5' minute
and metric_name in ( 'Database Time Per Sec'
                    ,'CPU Usage Per Sec'
                    ,'Background Time Per Sec'
                    ,'Background CPU Usage Per Sec'
                    ,'Host CPU Usage Per Sec'
                   )
group by h.begin_time, h.end_time
order by h.begin_time, h.end_time
/
col beg_time       clear;
col end_time       clear;
col db_time        clear;
col cpu            clear;
col bg_db_time     clear;
col bg_cpu         clear;
col host_cpu       clear;
