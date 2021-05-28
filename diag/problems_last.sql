set feed off;
col 1 new_val 1 noprint;
select 1 from dual where 1=0;
select nvl('&1',10) "1" from dual;
set feed on;

col PROBLEM_KEY for a150;
col CON_ID      for 99999
col "SR/BUG#"   for a10;
col FIRST_INC   for 9999999;
col LAST_INC    for 9999999;
select
     PROBLEM_ID
    ,CON_ID
    ,FIRST_INCIDENT as FIRST_INC
    ,LAST_INCIDENT  as LAST_INC
    ,to_char(FIRSTINC_TIME,'yyyy-mm-dd hh24:mi:ss') FIRSTINC_TIME
    ,to_char(LASTINC_TIME,'yyyy-mm-dd hh24:mi:ss') LASTINC_TIME
    ,SERVICE_REQUEST 
     ||'/'
     ||replace(BUG_NUMBER,chr(0)) as "SR/BUG#"
    ,PROBLEM_KEY
--    ,IMPACT1
--    ,IMPACT2
--    ,IMPACT3
--    ,IMPACT4
--    ,CON_UID
from v$diag_problem
order by problem_id desc
fetch first &1 rows only;

undef 1;