set serverout on;
declare
  level# int;
begin
  for event# in 1..10999 loop
     sys.dbms_system.read_ev (event#, level#);
     if level# != 0  then
        dbms_output.put_line('Event #'||event#||' level:'||level# );
     end if;
  end loop;
end;
/
set serverout off;