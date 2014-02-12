prompt &_C_REVERSE *** Show stats delta through specified interval &_C_RESET
accept _sid       prompt 'Enter SID: '
accept _statmask  prompt 'Enter statmask: '
accept _tinterval prompt 'Enter interval(sec): '
accept _delta prompt 'Enter delta miniminum: '
set serverout on;
declare
   a ku$_ErrorLines;
   b ku$_ErrorLines;
   nformat constant varchar2(30):='999g999g999g999g999';
   
   function getstats(p_sid int,p_mask varchar2)
      return ku$_ErrorLines 
   is
      ret ku$_ErrorLines;
   begin
      select 
         ku$_ErrorLine(s.value,n.name)
         bulk collect into ret
      from v$sesstat s,v$statname n
      where s.STATISTIC#=n.STATISTIC#
        and s.sid = p_sid
        and regexp_like(n.name,p_mask,'i');
      return ret;
   end;

begin
   a:=getstats(&_SID,'&_statmask');
   dbms_lock.sleep(&_tinterval);
   b:=getstats(&_SID,'&_statmask');
   
   dbms_output.put_line(rpad('Statistic',50,'.')
                               ||rpad(' Delta',length(nformat))
                               ||'    '
                               ||rpad(' Start',length(nformat))
                               ||'    '
                               ||rpad(' End'  ,length(nformat))
                          );
   dbms_output.put_line(rpad('-',50+3*length(nformat)+10,'-'));
   
   for r in ( select 
                 ta.ERRORTEXT                   as statname
                ,ta.ERRORNUMBER                 as value1
                ,tb.ERRORNUMBER                 as value2
                ,tb.ERRORNUMBER-ta.ERRORNUMBER  as delta
              from table(cast(a as ku$_ErrorLines)) ta
                  ,table(cast(b as ku$_ErrorLines)) tb
              where 
                   ta.ERRORTEXT    = tb.ERRORTEXT
               and tb.ERRORNUMBER-ta.ERRORNUMBER >= &_delta
            )
   loop
      dbms_output.put_line(rpad(r.statname,50,'.')
                               ||to_char(r.delta, nformat)
                               ||'    '
                               ||to_char(r.value1,nformat)
                               ||'    '
                               ||to_char(r.value2,nformat)
                          );
   end loop;
end;
/
set serverout off;
undef _statmask _tinterval;
