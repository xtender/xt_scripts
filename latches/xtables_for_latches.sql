create view vx$kslltr_children as select * from x$kslltr_children;
create public synonym vx$kslltr_children for sys.vx$kslltr_children;
grant select on vx$kslltr_children to developer_awr;

create view vx$kslltr_parent as select * from x$kslltr_parent;
create public synonym vx$kslltr_parent for sys.vx$kslltr_parent;
grant select on vx$kslltr_parent to developer_awr;

create view vx$ksupr as select * from x$ksupr;
create public synonym vx$ksupr for sys.vx$ksupr;
grant select on vx$ksupr to developer_awr;

create view vx$kslld as select * from x$kslld;
create public synonym vx$kslld for sys.vx$kslld;
grant select on vx$kslld to developer_awr;
