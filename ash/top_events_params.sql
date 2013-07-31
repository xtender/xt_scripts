with top_events as (
      select 
          h.wait_class
         ,h.event
         ,h.p1,h.p1text
         ,h.p2,h.p2text
         ,h.p3,h.p3text
         ,cast(to_char(h.p1,'FM0XXXXXXXXXXXXXXX') as varchar2(12)) p1_hex
         ,case 
             when p1text='address' 
                then (select ll.NAME from v$latch ll where ll.ADDR=to_char(h.p1,'FM0XXXXXXXXXXXXXXX')) 
             else '' 
          end latch_name
         ,count(*) cnt
      --   ,h.current_obj#
      --   ,(select object_name from dba_objects o where o.object_id=h.current_obj#) curobj
      from gv$active_session_history h
      where h.sample_time>sysdate -1/24
      group by 
          h.wait_class
         ,h.event
         ,h.p1,h.p1text
         ,h.p2,h.p2text
         ,h.p3,h.p3text
      order by cnt desc
)
select
   *
from top_events
where rownum<=20
/
