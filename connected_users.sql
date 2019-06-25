col username for a30;
col machine for a40;
select username,machine,count(*) 
from v$session where username!='SYS' 
group by username,machine
/
col username clear;
col machine clear;
