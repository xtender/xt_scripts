set echo on;
select * from table(xt_connected_components.get_numbers(cursor(select 1 a, 1    b from dual union all select 1 a, 2 b from dual)));
select * from table(xt_connected_components.get_numbers(cursor(select 1 a, null b from dual union all select 1 a, 2 b from dual)));
select * from table(xt_connected_components.get_numbers(cursor(select 1 a, 1    b from dual union all select 3 a, 2 b from dual)));
select * from table(xt_connected_components.get_numbers(cursor(select 1 a, null b from dual union all select 3 a, 2 b from dual)));
select * from table(xt_connected_components.get_numbers(cursor(select level, level*2 from dual connect by level<=10)));

select * from table(xt_connected_components.get_strings(cursor(select '1,1' b from dual union all select '1, 2' b from dual)));
select * from table(xt_connected_components.get_strings(cursor(select '1'   b from dual union all select '1, 2' b from dual)));
select * from table(xt_connected_components.get_strings(cursor(select '1,1' b from dual union all select '3, 2' b from dual)));
select * from table(xt_connected_components.get_strings(cursor(select '1'   b from dual union all select '3, 2' b from dual)));
select * from table(xt_connected_components.get_strings(cursor(select level||','|| level*2 from dual connect by level<=10)));
set echo off;
