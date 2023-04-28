var s_mid refcursor;

declare t2 sys.ku$_ObjNumNamSet;
begin
     select
        ku$_ObjNumNam(value,name) as val
        bulk collect into t2
     from v$sesstat s join v$statname n using(statistic#)
     where sid=&&rs_sid
       and name like '&&rs_mask';
   open :s_mid for select t2 b from dual;
end;
/
