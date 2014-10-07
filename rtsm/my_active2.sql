col my_sqlid new_value my_sqlid noprint;
select
   sql_id as my_sqlid
from v$session ss
where 
      ss.osuser = sys_context('USERENV','OS_USER')
  and ss.status = 'ACTIVE'
  and ss.SID   != USERENV('SID')
order by ss.status;

@rtsm/sqlid &my_sqlid