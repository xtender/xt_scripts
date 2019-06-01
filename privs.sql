accept _GRANTEE     prompt  "GRANTEE[%]   :" default '%';
accept _OWNER       prompt  "OWNER[%]     :" default '%';
accept _TABLE_NAME  prompt  "TABLE_NAME[%]:" default '%';
accept _GRANTOR     prompt  "GRANTOR[%]   :" default '%';
accept _PRIVILEGE   prompt  "PRIVILEGE[%] :" default '%';

col GRANTEE    for a30;
col OWNER      for a30;
col TABLE_NAME for a30;
col GRANTOR    for a30;
col PRIVILEGE  for a30;

select *
from dba_tab_privs p
where 
    GRANTEE    like '&_GRANTEE'
and OWNER      like '&_OWNER'
and TABLE_NAME like '&_TABLE_NAME'
and GRANTOR    like '&_GRANTOR'
and PRIVILEGE  like '&_PRIVILEGE';

col GRANTEE    clear;
col OWNER      clear;
col TABLE_NAME clear;
col GRANTOR    clear;
col PRIVILEGE  clear;