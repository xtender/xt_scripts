accept xtable prompt "X$Table name: "
create view v&xtable as select * from &xtable;
create public synonym v&xtable for sys.v&xtable;
grant select on v&xtable to developer_awr;
