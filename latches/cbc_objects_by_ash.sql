with tr as (
      select 
          h.wait_class
         ,h.event
         ,h.SQL_ID
         ,h.SQL_CHILD_NUMBER
         
         ,h.SQL_OPNAME
         ,h.SQL_PLAN_LINE_ID
         ,h.SQL_PLAN_OPERATION
         ,h.SQL_PLAN_OPTIONS
         ,h.SQL_EXEC_START
         ,h.sql_exec_id
         /*
         ,h.PLSQL_ENTRY_OBJECT_ID
         ,h.PLSQL_ENTRY_SUBPROGRAM_ID
         ,h.PLSQL_OBJECT_ID
         ,h.PLSQL_SUBPROGRAM_ID
         */
   ,(select object_name from dba_objects o where o.object_id=h.plsql_entry_object_id) ple
   ,(select object_name from dba_objects o where o.object_id=h.plsql_object_id) plo
   ,(select object_name from dba_objects o where o.object_id=h.CURRENT_OBJ#) curr_obj
         ,h.CURRENT_OBJ#
         ,h.CURRENT_FILE#
         ,h.CURRENT_BLOCK#
         ,h.CURRENT_ROW#

         ,h.WAIT_TIME
         ,h.TIME_WAITED
         ,h.TIME_MODEL
         ,h.IS_SQLID_CURRENT
         ,h.BLOCKING_SESSION_STATUS
         ,h.p1,h.p1text
         ,h.p2,h.p2text
         ,h.p3,h.p3text
         ,cast(to_char(h.p1,'FM0XXXXXXXXXXXXXXX') as varchar2(12)) p1_hex
         ,case 
             when p1text='address' 
                then coalesce(
                              (select ll.NAME from v$latch ll where ll.ADDR=to_char(h.p1,'FM0XXXXXXXXXXXXXXX')) 
                             ,(select ll.NAME from v$latch_parent ll where ll.ADDR=to_char(h.p1,'FM0XXXXXXXXXXXXXXX'))
                             ,(select ll.NAME from v$latch_children ll where ll.ADDR=to_char(h.p1,'FM0XXXXXXXXXXXXXXX'))
                             )
             else '' 
          end latch_name
--         ,count(*) cnt
      --   ,h.current_obj#
      --   ,(select object_name from dba_objects o where o.object_id=h.current_obj#) curobj
      from gv$active_session_history h
      where h.sample_time>sysdate -1/24
        and event = 'latch: cache buffers chains'
)
select 
  sql_id
 ,sql_child_number
 ,sql_opname
 ,sql_plan_operation
 ,sql_plan_options
 ,ple
 ,plo
 ,curr_obj
 --,current_file#
 --,current_block#
 --,current_row#
 ,time_model
 ,is_sqlid_current
 ,blocking_session_status
-- ,p1,p1text
-- ,p2,p2text
-- ,p3,p3text
-- ,p1_hex
 ,latch_name
 ,sum(wait_time)    as sum_wait_time
 ,sum(time_waited)  as sum_time_waited
 ,count(*)          as cnt
 ,sum(count(*)) over(partition by curr_obj) cnt_by_obj
from tr
group by 
           sql_id
          ,sql_child_number
          ,sql_opname
          ,sql_plan_operation
          ,sql_plan_options
          ,ple
          ,plo
          ,curr_obj
          --,current_file#
          --,current_block#
          --,current_row#
          ,time_model
          ,is_sqlid_current
          ,blocking_session_status
--          ,p1,p1text
--          ,p2,p2text
--          ,p3,p3text
--          ,p1_hex
          ,latch_name
order by cnt_by_obj desc,cnt desc
