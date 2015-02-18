var out_c refcursor;

declare
   vt dbmsoutput_linesarray;
   cnt integer;
begin
   dbms_output.get_lines(vt,cnt);
   open :out_c for select COLUMN_VALUE as output from table(vt);
end;
/
col output for a200;
print out_c;
undef out_c
col output clear;