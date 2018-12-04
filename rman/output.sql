prompt ****************************************************
prompt * Start date accepts the following formats:
prompt *    yyyy-mm-dd
prompt *    yyyy-mm-dd hh24:mi:ss
prompt *    N  -- calculated as (trunc(sysdate)-N), so 0 is today's operations
prompt *
prompt * Default is trunc(sysdate)
prompt ****************************************************
accept _start prompt "Start date[trunc(sysdate)-3] or number of days: " default ""

col command_id  for a19;
col start_time  for a10;
col end_time    for a10;


COL RECID           NEW_VAL P_RECID       NOPRINT;
COL COMMAND_ID      NEW_VAL P_COMMAND_ID  NOPRINT;
COL START_TIME      NEW_VAL P_START_TIME  NOPRINT;
COL END_TIME        NEW_VAL P_END_TIME    NOPRINT;
COL OPERATION       NEW_VAL P_OPERATION   NOPRINT;
COL STATUS          NEW_VAL P_STATUS      NOPRINT;

COL LINE#       NOPRINT;

break on recid on command_id on start_time on end_time on operation on status skip page;
set pause on;

ttitle left -
     '###############################################################################################################' skip 1-
     '# RECID      : ' P_RECID       skip 1-
     '# COMMAND_ID : ' P_COMMAND_ID  skip 1-
     '# START_TIME : ' P_START_TIME  skip 1-
     '# END_TIME   : ' P_END_TIME    skip 1-
     '# OPERATION  : ' P_OPERATION   skip 1-
     '# STATUS     : ' P_STATUS      skip 2;


with 
 st as (
   select/*+ materialize */
     --s.sid,
     --s.parent_recid,
     s.recid,command_id
    ,to_char(start_time,'hh24:mi:ss') start_time
    ,to_char(end_time  ,'hh24:mi:ss') end_time
    ,operation||' '||object_type      operation
    ,status                      status
   from v$rman_status s 
   where start_time >= case 
                            when '&_start' is null then trunc(sysdate-3) 
                            when regexp_like('&_start','\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d') then to_date('&_start','yyyy-mm-dd hh24:mi:ss')
                            when regexp_like('&_start','\d\d\d\d-\d\d-\d\d') then to_date('&_start','yyyy-mm-dd')
                            when regexp_like('&_start','^\d+$') then sysdate-to_number('&_start')
                            else trunc(sysdate)
                        end
   and s.status not in ('RUNNING','COMPLETED') 
 )
   select --distinct command_id||' '||operation||' '||object_type||' '||status  errors 
     st.*
    --,o.recid as line#
    ,o.output
   from st
       ,v$rman_output o
   where 
     o.RMAN_STATUS_RECID=st.recid
     and (  o.output not like 'Backup Set%'
        and o.output not like '  Backup Piece%'
        and o.output not like 'input%'
        and o.output not like 'channel%'
        and o.output not like 'piece%'
     )
   order by --command_id,start_time,
     st.recid,o.recid;

undef _start;