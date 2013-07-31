set tab off timing off feedback off


accept sid -
       prompt 'Enter value for sid(blank for all): ' -
       default '%'

accept user -
       prompt 'Enter mask(like) for username(blank for all): ' -
       default '%'

accept osuser -
       prompt 'Enter mask(like) for OSuser(blank for local): ' -
       default ''


set termout off


COLUMN sid 		FORMAT  9999
COLUMN username	FORMAT  A15
COLUMN osuser 		FORMAT  A15

COLUMN sqltext 		FORMAT 	A40
COLUMN sql_id 		FORMAT	A15
COLUMN name 		FORMAT	A15
COLUMN "Size(KB)"  	FORMAT	999999

BREAK ON sid ON username ON osuser ON sqltext ON sql_id

set pagesize 50000

set termout on

select  s.sid
       ,s.username
       ,s.OSUSER
       ,(select substr(regexp_replace(sql_text,'\s{2,}',' '),1,40) from v$sql vs where vs.sql_id=s.sql_id and rownum=1) sqltext
       ,s.sql_id
       ,substr(name,9) name
       ,sum(value/1024) "Size(KB)"
from v$statname n
     ,v$session s
     ,v$sesstat t
where 
        s.sid=t.sid
    and n.statistic# = t.statistic#
    and s.type = 'USER'
    and s.username is not NULL

    and s.sid like '&&sid'
    and upper(s.username) like upper('&&user')
    and (
         upper(s.OSUSER) like upper('&&osuser')
         or s.OSUSER=sys_context('USERENV','OS_USER')
        )
    and s.STATUS='ACTIVE'
    and n.name in ('session pga memory'
                  ,'session pga memory max'
                  ,'session uga memory'
                  ,'session uga memory max')
group by 
    s.sid,s.username,s.osuser, s.sql_id,name
order by 1,2,3,4,5,6
/
set tab on timing on feedback on