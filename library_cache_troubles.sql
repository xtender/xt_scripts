accept timestamp_start prompt 'Start time(timestamp or minutes before): ';
accept timestamp_end   prompt 'End   time(timestamp): ';

col timestamp_start new_value timestamp_start noprint;
col timestamp_end   new_value timestamp_end   noprint;
select 
     case 
        when '&timestamp_start' is null 
           then to_char(systimestamp - interval '5' minute,'yyyy-mm-dd hh24:mi:ss')
        when translate('&timestamp_start','x0123456789','x') is null
           then to_char(systimestamp - interval '0&timestamp_start' minute,'yyyy-mm-dd hh24:mi:ss')
        else '&timestamp_start'
     end as timestamp_start
    ,nvl('&timestamp_end',to_char(systimestamp,'yyyy-mm-dd hh24:mi:ss')) as timestamp_end
from dual;

col mutex_object format a35;
col event        format a25

SELECT sample_id
      ,to_char(sample_time, 'hh24:mi:ss') sample_time
      ,session_id
      ,session_serial#
      ,sql_id
      ,event
      ,p1 IDN
      ,FLOOR(p2 / POWER(2, 4 * ws)) blocking_sid
      ,MOD(p2, POWER(2, 4 * ws)) shared_refcount
      ,FLOOR(p3 / POWER(2, 4 * ws)) location_id
      ,MOD(p3, POWER(2, 4 * ws)) sleeps
      ,CASE
          WHEN (event LIKE 'library cache:%' AND p1 <= power(2, 17)) THEN
           'library cache bucket: ' || p1
          ELSE
           (SELECT kglnaobj
            FROM   vx$kglob kgl_ob
            WHERE  kgl_ob.kglnahsh = p1
            AND    (kgl_ob.kglhdadr = kgl_ob.kglhdpar)
            and    rownum = 1)
       END mutex_object
FROM   (SELECT DECODE(INSTR(banner, '64'), 0, '4', '8') ws
        FROM   v$version
        WHERE  ROWNUM = 1) wordsize
      ,v$active_session_history
WHERE  
       p1text = 'idn'
AND    session_state = 'WAITING'
AND    sample_time --BETWEEN (sysdate - 30/1440) AND sysdate
            between nvl(timestamp'&timestamp_start',systimestamp-interval '10' minute)
                and nvl(timestamp'&timestamp_end'  ,systimestamp)
ORDER  BY sample_id
/
col mutex_object clear;
col event        clear;
