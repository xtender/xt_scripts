@inc/input_vars_init;

prompt Show top sessions by session statistic

accept _param prompt "Enter statname mask:"
col statistic#  format 999999999;
col name        format a60;
col class       format a60;
select 
   statistic#
 , name 
 , ltrim(
       decode( bitand( class,   1 ), 0, '', '+User'   )
     ||decode( bitand( class,   2 ), 0, '', '+Redo'   )
     ||decode( bitand( class,   4 ), 0, '', '+Enqueue')
     ||decode( bitand( class,   8 ), 0, '', '+Cache'  )
     ||decode( bitand( class,  16 ), 0, '', '+OS'     )
     ||decode( bitand( class,  32 ), 0, '', '+RAC'    )
     ||decode( bitand( class,  64 ), 0, '', '+SQL'    )
     ||decode( bitand( class, 128 ), 0, '', '+Debug'  )
     ,'+') class
from v$statname 
where lower(name) like lower('&_param')
order by 1;

col statistic#  clear;
col name        clear;
col class       clear;

accept _stat_id  prompt "Enter statistic#: ";
accept _interval prompt "Enter snap interval:" default 3

var c refcursor;

declare
   v_stat1 sys.ku$_objnumpairlist;
   v_stat2 sys.ku$_objnumpairlist;
   
   p_stat       int;
   p_interval   int:=&_interval; -- seconds
   
   cursor c_stats(p_statistic# int) is
      select 
         sys.ku$_objnumpair(
            st.SID
           ,st.value
         ) as numpair
      from v$sesstat st
      where st.STATISTIC#=p_statistic#;

begin
   if q'[&_stat_id]' is null then
      return;
   end if;
   p_stat := to_number('&_stat_id');
                      
   open c_stats(p_stat);
   fetch c_stats bulk collect into v_stat1;
   close c_stats;
   
   -- Sleep:
   dbms_lock.sleep(p_interval);
   -- Repeating:
   open c_stats(p_stat);
   fetch c_stats bulk collect into v_stat2;
   close c_stats;
   
   open :c for 
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
end;
/
print c;
undef _stat_id;
undef _param;
undef _interval;
