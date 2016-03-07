column component format a25 trunc;
column parameter format a30  ;

column initial_size format 99,999,999,999
column target_size format 99,999,999,999
column final_size format 99,999,999,999

select
        component,
        oper_type,
        oper_mode,
        parameter,
        initial_size,
        target_size,
        final_size,
        status,
        to_char(start_time,'dd-mon hh24:mi:ss') start_time,
        to_char(end_time,'dd-mon hh24:mi:ss')   end_time
from
        v$sga_resize_ops o
order by
        o.start_time
;  
