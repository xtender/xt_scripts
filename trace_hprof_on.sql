begin
  DBMS_HPROF.start_profiling (
    location => 'HPROF_DIR',
    filename => 'hprof_'||to_char(sysdate,'yyyy-mm-dd-hh24-mi-ss')||'_&test..trc'
  );
end;
/