select username
      ,user_id 
      ,account_status
      ,created
      ,default_tablespace
      ,u.temporary_tablespace
from dba_users u 
where 1=1
--and u.created > (select max(sysaux.created) from dba_users sysaux where sysaux.default_tablespace='SYSAUX')
--and u.user_id > (select max(sysaux.user_id) from dba_users sysaux where sysaux.default_tablespace='SYSAUX')
 and u.created>(select created from v$database)
 and u.account_status not like '%LOCKED%'
order by created desc
/
