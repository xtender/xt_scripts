column event_unit       format a15;
column event_unit_kind  format a15;
column event_comment    format a50;
select runid,
       event_seq,
       event_unit,
       event_unit_kind,
       event_line,
       stack_depth,
       event_comment,
       decode(event_kind,
              54,
              sum(decode(event_kind, 54, 1)) over(order by event_seq)) sql_invoke
  from sys.plsql_trace_events
 where runid = (select max(runid) from sys.plsql_trace_events);
column event_unit       clear;
column event_unit_kind  clear;
column event_comment    clear;