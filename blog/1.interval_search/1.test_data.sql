create table test_table(
   beg_date date
  ,end_date date
  ,padding  varchar2(10)
);
declare
  procedure p_insert(
    start_date       date
   ,end_date         date
   ,step_minutes     number
   ,duration_minutes number
  ) is
  begin
    insert/*+ append */ into test_table(beg_date,end_date,padding)
    select 
      start_date + n * numtodsinterval(step_minutes,'minute')
     ,start_date + n * numtodsinterval(step_minutes,'minute') + numtodsinterval(duration_minutes,'minute')
     ,'0123456789'
    from xmltable('0 to xs:integer(.)' 
          passing ceil( (end_date - start_date)*24*60/step_minutes)
          columns n int path '.'
         );
    commit;
  end;
begin
  -- 5 min intervals every 5 minutes: 00:00-00:15, 00:05-00:20,etc:
  --p_insert(date'2000-01-01',sysdate, 5, 5);
  -- 5 min intervals every 5 minutes starting from 00:02 : 00:02-00:07, 00:07-00:12,etc
  p_insert(date'2000-01-01'+interval'2'minute,sysdate, 5, 5);
  -- 15 min intervals every 5 minutes: 00:00-00:15, 00:05-00:20,etc:
  p_insert(date'2000-01-01',sysdate, 5, 15);
  -- 30 min intervals every 15 minutes: 00:00-00:30, 00:15-00:45,etc:
  p_insert(date'2000-01-01',sysdate, 15, 30);
  -- 1 hour intervals every 15 minutes: 00:00-01:00, 00:15-01:15,etc:
  p_insert(date'2000-01-01',sysdate, 15, 60);
  -- 2 hour intervals every 20 minutes: 00:00-02:00, 00:20-02:00,etc:
  p_insert(date'2000-01-01',sysdate, 20, 120);
  -- 7 days intervals every 60 minutes:
  p_insert(date'2000-01-01',sysdate, 60, 7*24*60);
  -- 30 days intervals every 1 hour:
  p_insert(date'2000-01-01',sysdate, 60, 30*24*60);
  -- 120 days intervals every 7 days:
  p_insert(date'2000-01-01',sysdate, 7*24*60, 120*24*60);
  -- 400 days intervals every 30 days:
  p_insert(date'2000-01-01',sysdate, 30*24*60, 400*24*60);
end;
/
create index ix_beg_end on test_table(beg_date,end_date);
create index ix_end_beg on test_table(end_date,beg_date);
