declare
   cnt int := 30;
   cursor c(p_sid int) is 
      select 
             to_char(systimestamp,'hh24:mi:ss.FF') tm
            ,nvl(s.sql_id,'---') sql_id
            ,s.event,s.WAIT_CLASS,s.WAIT_TIME,s.WAIT_TIME_MICRO
            ,(select object_name from dba_objects o where o.object_id=s.ROW_WAIT_OBJ#) obj
            ,s.ROW_WAIT_OBJ#
            --,s.ROW_WAIT_FILE#,s.ROW_WAIT_BLOCK#,s.ROW_WAIT_ROW# 
      from v$session s 
      where sid=p_sid;
      
   type t_tr is table of c%rowtype;
   r    c%rowtype;
   tr   t_tr;
   
   procedure print_r(r r%type) is
      s varchar2(4000);
   begin
      s:=utl_lms.format_message(
            '%s %s %s %s %s %s %s %s'
           ,r.tm
           ,r.sql_id
           ,rpad(r.event           ,30)
           ,rpad(r.WAIT_CLASS      ,30)
           ,rpad(r.WAIT_TIME       ,10)
           ,rpad(r.WAIT_TIME_MICRO ,10)
           ,rpad(r.obj             ,30)
           ,rpad(r.ROW_WAIT_OBJ#   ,6)
      );
                                 
      dbms_output.put_line( s );
   end;
   
begin
   tr:= t_tr();
   tr.extend(cnt);
   for i in 1..cnt loop
      open c(&sid);
      fetch c into tr(i);
      close c;
      dbms_lock.sleep(0.01);
   end loop;
   
   for i in 1.. cnt loop
      print_r(tr(i));
   end loop;
end;
/
