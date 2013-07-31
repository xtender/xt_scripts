@sqlplus_store
prompt Choose which parameter will be used:
prompt    1. session logical reads     [default] 
prompt    2. physical read bytes
prompt    3. physical read total bytes
prompt    4. CPU used by this session
accept _param prompt "Enter number:" default 1
accept _interval prompt "Enter snap interval:" default 3

set serverout on feed off timing off;

declare
   v_stat1 sys.ku$_objnumpairlist;
   v_stat2 sys.ku$_objnumpairlist;
   
   p_stat       int:=&_param;
   p_interval   int:=&_interval; -- seconds
   
   cursor c_stats(p_statistic# int) is
      select 
         sys.ku$_objnumpair(
            st.SID
           ,st.value
         ) as numpair
      from v$sesstat st
      where st.STATISTIC#=p_statistic#;

   cursor c_top is 
      with s_top(sid,delta) as
           (
            select *
            from (
                 select
                    t1.num1            as sid
                   ,t2.num2-t1.num2    as delta
                 from table(v_stat1) t1
                     ,table(v_stat2) t2
                 where t1.num1 = t2.num1
                 order by delta desc
                 )
            where rownum<=10
           )
      select--+ use_nl(t s) leading(t s) no_merge(t)
         t.sid,t.delta
        ,s.username
        ,s.program
        ,s.sql_id
        ,s.osuser
        ,s.event
        ,s.status
      from s_top     t
          ,v$session s
      where s.sid=t.sid
      order by 2 desc;

begin
   -- You can change this to any stat# from v$statname:
   select statistic# into p_stat 
   from v$statname 
   where name = decode( &_param
                        ,1,'session logical reads'
                        ,2,'physical read bytes'
                        ,3,'physical read total bytes'
                        ,4,'CPU used by this session'
                      );
                      
   open c_stats(p_stat);
   fetch c_stats bulk collect into v_stat1;
   close c_stats;
   
   -- Sleep:
   dbms_lock.sleep(p_interval);
   -- Repeating:
   open c_stats(p_stat);
   fetch c_stats bulk collect into v_stat2;
   close c_stats;
   
   dbms_output.put_line(lpad('-',152,'-'));
   
   dbms_output.put_line(
       utl_lms.format_message(
        '| %s | %s | %s | %s | %s | %s | %s | %s | %s'
        , lpad('SID     ' ||' ', 5,' ')
        , lpad('DELTA   ' ||' ',15,' ')
        , rpad('USERNAME' ||' ',25,' ')
        , rpad('PROGRAM ' ||' ',22,' ')
        , lpad('SQL_ID  ' ||' ',15,' ')
        , rpad('OSUSER  ' ||' ',15,' ')
        , lpad('EVENT   ' ||' ',15,' ')
        , lpad('STATUS  ' ||' ',15,' ')
        ));
   
   dbms_output.put_line(lpad('-',152,'-'));
   
   for r in c_top
   loop
      dbms_output.put_line(
         utl_lms.format_message(
           '| %s | %s | %s | %s | %s | %s | %s | %s | %s'
           , lpad(r.sid      ||' ', 5,' ')
           , lpad(r.delta    ||' ',15,' ')
           , rpad(r.username ||' ',25,' ')
           , rpad(r.program  ||' ',22,' ')
           , lpad(r.sql_id   ||' ',15,' ')
           , rpad(r.osuser   ||' ',15,' ')
           , lpad(r.event    ||' ',15,' ')
           , lpad(r.status   ||' ',15,' ')
         ));
   end loop;
   dbms_output.put_line(lpad('-',152,'-'));
end;
/
