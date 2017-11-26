col short_name  format a20              heading 'Load Profile'
col per_sec     format 999,999,999.9    heading 'Per Second'
col per_tx      format 999,999,999.9    heading 'Per Transaction'
set colsep '   '
 
select lpad(short_name, 20, ' ') short_name
     , per_sec
     , per_tx from
    (select short_name
          , max(decode(typ, 1, value)) per_sec
          , max(decode(typ, 2, value)) per_tx
          , max(m_rank) m_rank 
       from
        (select /*+ use_hash(s) */
                m.short_name
              , s.value * coeff value
              , typ
              , m_rank
           from v$sysmetric s,
               (select 'Database Time Per Sec'                      metric_name, 'DB Time' short_name, .01 coeff, 1 typ, 1 m_rank from dual union all
                select 'CPU Usage Per Sec'                          metric_name, 'DB CPU' short_name, .01 coeff, 1 typ, 2 m_rank from dual union all
                select 'Redo Generated Per Sec'                     metric_name, 'Redo size' short_name, 1 coeff, 1 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Sec'                      metric_name, 'Logical reads' short_name, 1 coeff, 1 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Sec'                   metric_name, 'Block changes' short_name, 1 coeff, 1 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Sec'                     metric_name, 'Physical reads' short_name, 1 coeff, 1 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Sec'                    metric_name, 'Physical writes' short_name, 1 coeff, 1 typ, 7 m_rank from dual union all
                select 'User Calls Per Sec'                         metric_name, 'User calls' short_name, 1 coeff, 1 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Sec'                  metric_name, 'Parses' short_name, 1 coeff, 1 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Sec'                   metric_name, 'Hard Parses' short_name, 1 coeff, 1 typ, 10 m_rank from dual union all
                select 'Logons Per Sec'                             metric_name, 'Logons' short_name, 1 coeff, 1 typ, 11 m_rank from dual union all
                select 'Executions Per Sec'                         metric_name, 'Executes' short_name, 1 coeff, 1 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Sec'                     metric_name, 'Rollbacks' short_name, 1 coeff, 1 typ, 13 m_rank from dual union all
                select 'User Transaction Per Sec'                   metric_name, 'Transactions' short_name, 1 coeff, 1 typ, 14 m_rank from dual union all
                select 'User Rollback UndoRec Applied Per Sec'      metric_name, 'Applied urec' short_name, 1 coeff, 1 typ, 15 m_rank from dual union all
                select 'Redo Generated Per Txn'                     metric_name, 'Redo size' short_name, 1 coeff, 2 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Txn'                      metric_name, 'Logical reads' short_name, 1 coeff, 2 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Txn'                   metric_name, 'Block changes' short_name, 1 coeff, 2 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Txn'                     metric_name, 'Physical reads' short_name, 1 coeff, 2 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Txn'                    metric_name, 'Physical writes' short_name, 1 coeff, 2 typ, 7 m_rank from dual union all
                select 'User Calls Per Txn'                         metric_name, 'User calls' short_name, 1 coeff, 2 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Txn'                  metric_name, 'Parses' short_name, 1 coeff, 2 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Txn'                   metric_name, 'Hard Parses' short_name, 1 coeff, 2 typ, 10 m_rank from dual union all
                select 'Logons Per Txn'                             metric_name, 'Logons' short_name, 1 coeff, 2 typ, 11 m_rank from dual union all
                select 'Executions Per Txn'                         metric_name, 'Executes' short_name, 1 coeff, 2 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Txn'                     metric_name, 'Rollbacks' short_name, 1 coeff, 2 typ, 13 m_rank from dual union all
                select 'User Transaction Per Txn'                   metric_name, 'Transactions' short_name, 1 coeff, 2 typ, 14 m_rank from dual union all
                select 'User Rollback Undo Records Applied Per Txn' metric_name, 'Applied urec' short_name, 1 coeff, 2 typ, 15 m_rank from dual) m
          where m.metric_name = s.metric_name
            and s.intsize_csec > 5000
            and s.intsize_csec < 7000)
      group by short_name)
 order by m_rank;