--exec sys.dbms_result_cache.memory_report(true);
var rc refcursor;
declare
   vc sys.ku$_vcnt;
   v_vc_out dbmsoutput_linesarray;
   v_cnt    integer;
begin
   dbms_output.enable(buffer_size => NULL);
   sys.dbms_result_cache.memory_report(true);
   dbms_output.get_lines(v_vc_out, v_cnt);
   open :rc for select * from table(v_vc_out);
end;
/
print rc
