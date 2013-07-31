@?/rdbms/admin/tracetab.sql
create public synonym plsql_trace_runs      for plsql_trace_runs;
create public synonym plsql_trace_events    for plsql_trace_events;
create public synonym plsql_trace_runnumber for plsql_trace_runnumber;
grant all on plsql_trace_runs               to public;
grant all on plsql_trace_events             to public;
grant all on plsql_trace_runnumber          to public;
