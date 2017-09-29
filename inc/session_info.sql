define db_id       =""
define db_name     =""
define db_inst_id  =""
define db_host_name=""
define db_version  =""
define db_edition  =""
define db_role     =""
define my_user     ="&_USER"
define my_sid      =""
define my_host     =""
define my_ip       =""
define my_is_dba   =""
define my_serial   =""
define my_spid     =""
define my_os_pid   =""
define my_pid      =""
define my_ora_pid  =""
define my_os_user  =""

col db_id           new_val     db_id           noprint;
col db_name         new_val     db_name         noprint;
col db_inst_id      new_val     db_inst_id      noprint;
col db_host_name    new_val     db_host_name    noprint;
col db_version      new_val     db_version      noprint;
col db_edition      new_val     db_edition      noprint;
col db_role         new_val     db_role         noprint;
col my_sid          new_val     my_sid          noprint;
col my_host         new_val     my_host         noprint;
col my_ip           new_val     my_ip           noprint;
col my_is_dba       new_val     my_is_dba       noprint;
col my_serial       new_val     my_serial       noprint;
col my_spid         new_val     my_spid         noprint;
col my_os_pid       new_val     my_os_pid       noprint;
col my_pid          new_val     my_pid          noprint;
col my_ora_pid      new_val     my_ora_pid      noprint;
col my_os_user      new_val     my_os_user      noprint;

select--+ rule ordered
   db.dbid                                      as db_id
  ,nvl2( db.db_unique_name
           ,db.name
              ||'('
              ||db.db_unique_name
              ||')'
           ,db.name
       )                                        as db_name
  ,trim(i.instance_number)                      as db_inst_id
  ,i.host_name                                  as db_host_name
  ,i.version                                    as db_version
&_IF_ORA12_OR_HIGHER ,i.edition                 as db_edition
&_IF_LOWER_THAN_ORA12 ,decode((select count(*) from v$version where lower(banner) like '%enterpri%'),1,'EE','SE') as db_edition
  ,i.instance_role                              as db_role
  ,trim(userenv('SID')                        ) as my_sid
  ,trim(sys_context('USERENV','HOST')         ) as my_host
  ,trim(sys_context('USERENV','IP_ADDRESS')   ) as my_ip
  ,trim(sys_context('USERENV','ISDBA')        ) as my_is_dba
  ,trim(sys_context('USERENV','OS_USER')      ) as my_os_user
  ,trim(s.serial#                             ) as my_serial
  ,p.spid                                       as my_spid
  ,p.spid                                       as my_os_pid
  ,p.pid                                        as my_pid
  ,p.pid                                        as my_ora_pid
from v$database db
    ,v$instance i
    ,v$session  s
    ,v$process  p
where 
      s.sid=userenv('SID')
  and s.paddr = p.addr;

col db_id           clear;
col db_name         clear;
col db_inst_id      clear;
col db_host_name    clear;
col db_version      clear;
col my_sid          clear;
col my_host         clear;
col my_ip           clear;
col my_is_dba       clear;
col my_serial       clear;
col my_spid         clear;
col my_os_pid       clear;
col my_pid          clear;
col my_ora_pid      clear;
col my_os_user      clear;