col "SYS.STANDARD.SQLERRM" format a70
select sys.standard.sqlerrm(-abs(&1)) as "SYS.STANDARD.SQLERRM" from dual;
