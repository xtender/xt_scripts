with
   function rawblob_to_clob(b blob) return clob 
   is
      res             clob;
      tmp             raw(32000);
      i               int:=1;
      l               int;
   begin
      l:=length(b);
      while i<l loop
         tmp:=dbms_lob.substr(b,32000,i);
         res:=res||utl_raw.cast_to_varchar2(tmp);
         i:=i+32000; -- I use 32000 instead of length(tmp)
                     -- to reduce extra work
      end loop;
      return res;
   end;
select rawblob_to_clob(r.binary_output) output
from DBA_SCHEDULER_JOB_RUN_DETAILS r
where job_name = '&job_name'
/
