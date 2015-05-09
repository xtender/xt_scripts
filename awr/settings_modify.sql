accept _retention_days prompt "Retention,days[30]: " default 30;
accept _interval       prompt "Interval,min[30]: "   default 30;
accept _topn           prompt "Top N SQL's[100]: "   default 100;
BEGIN
  DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings(
     retention => &_retention_days*1440,
     interval  => &_interval,
     topnsql   => &_topn
  );
END;
/
accept _retention_days;
accept _interval      ;
accept _topn          ;
