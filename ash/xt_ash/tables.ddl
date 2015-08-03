-- ASH:
create table xt$active_session_history as 
  select * from v$active_session_history h where 1=0;
create index ix$ash_stime on xt$active_session_history(sample_time);

-- SQL:
create table xt$sql_text(
    sql_id varchar2(13), 
    sql_text clob, 
    constraint xt$sql_text_pk primary key(sql_id)
)
  lob(sql_text) store as 
     securefile sqltext_cmprss(
         enable storage in row
         compress high
       );

-- RTSM:
create table xt$sql_monitor as
  select * from v$sql_monitor where 1=0;
create index ix_sql_monitor_1 on xt$sql_monitor(LAST_REFRESH_TIME);
create index ix_sql_monitor_2 on xt$sql_monitor(SQL_EXEC_START);
create index ix_sql_monitor_3 on xt$sql_monitor(SQL_ID,KEY,SQL_EXEC_ID,SID);

-- RTSM plan_monitor:
create table xt$sql_plan_monitor as
  select * from  v$sql_plan_monitor where 1=0;
create index ix_sql_plan_monitor_1 on xt$sql_plan_monitor(LAST_REFRESH_TIME);
create index ix_sql_plan_monitor_2 on xt$sql_plan_monitor(SQL_EXEC_START);
create index ix_sql_plan_monitor_3 on xt$sql_plan_monitor(SQL_ID,KEY,SQL_EXEC_ID,SID);

-- XT_ASH params:
create table xt$ash_params( 
   param varchar2(30) not null
  ,value varchar2(30)
  ,constraint xt_ash_pk    primary key (param)
  ,constraint xt_ash_upper check(param=upper(param))
);
