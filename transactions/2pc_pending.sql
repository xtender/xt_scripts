col local_tran_id   for a20;
col global_tran_id  for a84;
col state           for a12;
col tran_comment    for a20;
col os_user         for a20;
col os_terminal     for a20;
col host            for a30;
col db_user         for a30;

select
     LOCAL_TRAN_ID
    ,STATE
    ,MIXED
    ,ADVICE
    ,TRAN_COMMENT
    ,FAIL_TIME
    ,FORCE_TIME
    ,RETRY_TIME
    ,OS_USER
    ,OS_TERMINAL
    ,HOST
    ,DB_USER
    ,COMMIT#
    ,GLOBAL_TRAN_ID
from dba_2pc_pending;
col local_tran_id   clear;
col global_tran_id  clear;
col state           clear;
col tran_comment    clear;
col os_user         clear;
col os_terminal     clear;
col host            clear;
col db_user         clear;