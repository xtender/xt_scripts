var s_beg refcursor;
def rs_sid=&1
def rs_mask="&2"

begin
   open :s_beg for
         select ku$_ObjNumNam(value,name) as val
         from v$sesstat s join v$statname n using(statistic#)
         where sid=decode(&&rs_sid+0,0,userenv('sid'),&&rs_sid)
           and name like nvl('&&rs_mask','%');
end;
/
