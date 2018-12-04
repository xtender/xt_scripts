prompt ****************************************************
prompt * Start date accepts the following formats:
prompt *    yyyy-mm-dd
prompt *    yyyy-mm-dd hh24:mi:ss
prompt *    N  -- calculated as (trunc(sysdate)-N), so 0 is today's operations
prompt *
prompt * Default is trunc(sysdate)
prompt ****************************************************
accept _start prompt "Start date[trunc(sysdate)-3] or number of days: " default ""

select recid, parent_recid, row_type, command_id, operation, object_type, status
from v$rman_status 
where start_time >= case 
                        when '&_start' is null then trunc(sysdate-3) 
                        when regexp_like('&_start','\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d') then to_date('&_start','yyyy-mm-dd hh24:mi:ss')
                        when regexp_like('&_start','\d\d\d\d-\d\d-\d\d') then to_date('&_start','yyyy-mm-dd')
                        when regexp_like('&_start','^\d+$') then sysdate-to_number('&_start')
                        else trunc(sysdate)
                    end
order by start_time desc;

undef _start;