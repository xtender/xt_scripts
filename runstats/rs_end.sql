var s_end refcursor;

declare t3 sys.ku$_ObjNumNamSet;
begin
     select
        ku$_ObjNumNam(value,name) as val
        bulk collect into t3
     from v$sesstat s join v$statname n using(statistic#)
     where sid=&&rs_sid
       and name like '&&rs_mask';
   open :s_end for select t3 from dual;
end;
/
-- compare:
var res refcursor;
declare
   rs_beg    ku$_ObjNumNamSet;
   rs_mid    ku$_ObjNumNamSet;
   rs_end    ku$_ObjNumNamSet;
begin
   fetch :s_beg into rs_beg;
   fetch :s_mid into rs_mid;
   fetch :s_end into rs_end;

   open :res for
      with 
         b as (select t.name,t.obj_num val from table(rs_beg)t)
        ,m as (select t.name,t.obj_num val from table(rs_mid)t)
        ,e as (select t.name,t.obj_num val from table(rs_end)t)
        ,d as (
               select b.name
                     ,m.val-b.val as delta1
                     ,e.val-m.val as delta2
               from b,m,e
               where b.name=m.name
                 and b.name=e.name
         )
      select * 
      from d
      where  delta1!=delta2 
         or (nvl('&&rs_mask','%')!='%' and name like '&&rs_mask')
      ;
end;
/
print res
