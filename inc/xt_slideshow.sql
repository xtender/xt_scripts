create or replace function xt_slideshow(
   sqltext varchar2
  ,p_count int := 10  -- snaps count
  ,p_pause int := 500 -- milliseconds
  ,p_len   int := 80  -- linesize
   )
   return sys.odcivarchar2list pipelined 
is
   c_cls constant varchar2(4):=chr(27)||chr(91)||chr(50)||chr(74);
   v_output varchar2(4000);
begin
   for i in 1..p_count loop
      pipe row(c_cls||'Snap #'||i);
      execute immediate sqltext into v_output;
      pipe row(v_output);
      dbms_lock.sleep(p_pause/1000);
   end loop;
end;
/
