var s_mid refcursor;

begin
   open :s_mid for
         select ku$_ObjNumNam(value,name) as val
         from v$sesstat s join v$statname n using(statistic#)
         where sid=decode(&&rs_sid+0,0,userenv('sid'),&&rs_sid)
           and name like nvl('&&rs_mask','%');
end;
/
