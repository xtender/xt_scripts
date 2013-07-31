/* cursors in memory: */
create or replace force view vx$kglcursor 
       as select * from x$kglcursor;
create public synonym vx$kglcursor  for sys.vx$kglcursor;
grant select on vx$kglcursor to DEVELOPER_AWR;

create or replace force view vx$ksmhp 
       as select * from x$ksmhp;
create public synonym vx$ksmhp  for sys.vx$ksmhp;
grant select on vx$ksmhp to DEVELOPER_AWR;
