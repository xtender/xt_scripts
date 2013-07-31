select * from (
   select
      event,
      trim(to_char(p1, 'XXXXXXXXXXXXXXXX')) latch_addr,
      trim(round(ratio_to_report(count(*)) over () * 100, 1))||'%' pct,
      count(*)
   from
      v$active_session_history
   where
      event = 'latch: cache buffers chains'
      and session_state = 'WAITING'
   group by event,p1
   order by count(*) desc
)
where rownum <= 10
/
