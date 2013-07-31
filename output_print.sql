var out_c refcursor;

declare
   vt dbmsoutput_linesarray;
   cnt integer;
begin
   dbms_output.get_lines(vt,cnt);
   open :out_c for select * from table(vt);
end;
/
print out_c;
undef out_c
