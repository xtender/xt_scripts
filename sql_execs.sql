@inc/input_vars_init;
set timing off termout off;
col 2 new_val 2 noprint
col 3 new_val 3 noprint
select
   nvl(to_number('&2'),5) "2"
  ,nvl(to_number('&3'),1) "3"
from dual;
set termout on;
prompt 
prompt Execution number of sqlid='&1', &2 snaps(param #2), interval &3 seconds(param #3);
var c refcursor;
declare 
   type t_cnt is table of sys.ku$_objnumpairlist;
   v_cnt    t_cnt:=t_cnt();
   v_snaps  int:=nvl(to_number('&2'),5);
   v_period int:=nvl(to_number('&3'),1);
   
   v_res_sql clob;
   
   cursor c_cnt(p_sqlid varchar2) is 
      select 
         sys.ku$_objnumpair(
           child_number
          ,executions
         )
      from v$sql s
      where s.sql_id=p_sqlid;
      
   procedure p_snap(n int) is
   begin
      open c_cnt('&1');
      fetch c_cnt bulk collect into v_cnt(n);
      close c_cnt;
   end;

begin
   /* initialization: */
   v_cnt.extend(10);
   for i in 1..10 loop
      v_cnt(i):=sys.ku$_objnumpairlist();
   end loop;
   /* main: */
   for i in 1..v_snaps+1 loop
      if i>0 then
         dbms_lock.sleep(v_period);
      end if;
      p_snap(i);
   end loop;
   
   v_res_sql:=q'[
   select 
      coalesce(t0.num1,t1.num1,t2.num1,t3.num1,t4.num1,t5.num1,t6.num1,t7.num1,t8.num1,t9.num1) child_n
     ,t1.num2-t0.num2 d1
     ,t2.num2-t1.num2 d2
     ,t3.num2-t2.num2 d3
     ,t4.num2-t3.num2 d4
     ,t5.num2-t4.num2 d5
     ,t6.num2-t5.num2 d6
     ,t7.num2-t6.num2 d7
     ,t8.num2-t7.num2 d8
     ,t9.num2-t8.num2 d9
   from                 table(cast(:0 as sys.ku$_objnumpairlist)) t0
        full outer join table(cast(:1 as sys.ku$_objnumpairlist)) t1 on t0.num1=t1.num1
        full outer join table(cast(:2 as sys.ku$_objnumpairlist)) t2 on t1.num1=t2.num1
        full outer join table(cast(:3 as sys.ku$_objnumpairlist)) t3 on t2.num1=t3.num1
        full outer join table(cast(:4 as sys.ku$_objnumpairlist)) t4 on t3.num1=t4.num1
        full outer join table(cast(:5 as sys.ku$_objnumpairlist)) t5 on t4.num1=t5.num1
        full outer join table(cast(:6 as sys.ku$_objnumpairlist)) t6 on t5.num1=t6.num1
        full outer join table(cast(:7 as sys.ku$_objnumpairlist)) t7 on t6.num1=t7.num1
        full outer join table(cast(:8 as sys.ku$_objnumpairlist)) t8 on t7.num1=t8.num1
        full outer join table(cast(:9 as sys.ku$_objnumpairlist)) t9 on t8.num1=t9.num1
   ]';
   open :c for v_res_sql 
     using 
       v_cnt(1),v_cnt(2),v_cnt(3),v_cnt(4),v_cnt(5)
      ,v_cnt(6),v_cnt(7),v_cnt(8),v_cnt(9),v_cnt(10);
end;
/
print c;
@inc/input_vars_undef;
