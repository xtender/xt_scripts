var log_history number;
exec  DBMS_SCHEDULER.get_scheduler_attribute('LOG_HISTORY', :log_history);
print log_history;