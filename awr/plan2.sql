col xplan for a200;
select 
        dbms_xplan.display_plan(
           table_name   => 'dba_hist_sql_plan'
          ,format       => 'advanced'
          ,filter_preds => q'[sql_id='&1']'
          ,type         => 'text'
        ) xplan
from dual;
col xplan clear;