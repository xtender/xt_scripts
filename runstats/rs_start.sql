@inc/input_vars_init
var s_beg refcursor;
accept rs_sid prompt "SID[current sid=&my_sid]: " default &my_sid
accept rs_mask prompt "Statname mask[%]: " default "%"

declare t1 sys.ku$_ObjNumNamSet;
begin
     select
        ku$_ObjNumNam(value,name) as val 
        bulk collect into t1
     from v$sesstat s join v$statname n using(statistic#)
     where sid=&rs_sid
       and name like '&&rs_mask';
   open :s_beg for select t1 a from dual;
end;
/
