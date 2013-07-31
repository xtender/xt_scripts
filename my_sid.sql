col sid head "My SID" for a9
select sys_context('userenv','sid') sid from dual;
col sid clear
