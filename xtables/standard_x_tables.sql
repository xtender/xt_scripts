/* parameters: */
create or replace force view vx$ksppcv 
       as select * from x$ksppcv;
create public synonym vx$ksppcv  for sys.vx$ksppcv;
grant select on vx$ksppcv to DEVELOPER_AWR;

create or replace force view vx$ksppi 
       as select * from x$ksppi;
create public synonym vx$ksppi  for sys.vx$ksppi;
grant select on vx$ksppi to DEVELOPER_AWR;
/* latches and mutexes: */
create or replace force view vx$kglpn 
       as select * from x$kglpn;
create public synonym vx$kglpn  for sys.vx$kglpn;
grant select on vx$kglpn to DEVELOPER_AWR;

create or replace force view vx$kgllk 
       as select * from x$kgllk;
create public synonym vx$kgllk  for sys.vx$kgllk;
grant select on vx$kgllk to DEVELOPER_AWR;

create or replace force view vx$ksuse 
       as select * from x$ksuse;
create public synonym vx$ksuse  for sys.vx$ksuse;
grant select on vx$ksuse to DEVELOPER_AWR;

create or replace force view vx$kglob 
       as select * from x$kglob;
create public synonym vx$kglob  for sys.vx$kglob;
grant select on vx$kglob to DEVELOPER_AWR;
/* valid_values: */
create or replace force view vx$kspvld_values 
       as select * from x$kspvld_values;
create public synonym vx$kspvld_values  for sys.vx$kspvld_values;
grant select on vx$kspvld_values to DEVELOPER_AWR;
