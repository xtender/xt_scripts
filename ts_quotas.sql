col username        for a30;
col tablespace_name for a30;
col MBytes          for a12;
col Max_MBytes      for a12;
col "PCT Used"      for 990.9;
select  
    tq.username
   ,tq.tablespace_name
   ,to_char(tq.bytes     /1024,'999g999g999',q'[NLS_NUMERIC_CHARACTERS=', ']') "MBytes"
   ,to_char(tq.max_bytes /1024,'999g999g999',q'[NLS_NUMERIC_CHARACTERS=', ']') "Max_MBytes"
   ,tq.blocks
   ,tq.max_blocks
   ,round(100*tq.blocks / tq.max_blocks,1) "PCT Used"
from 
    dba_ts_quotas tq
where 
     tq.username like upper('&1')
order by username,tablespace_name;

col username        clear;
col tablespace_name clear;
col MBytes          clear;
col Max_MBytes      clear;
col "PCT Used"      clear;