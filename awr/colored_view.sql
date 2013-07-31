@inc/input_vars_init;
select * 
from DBA_HIST_COLORED_SQL cs
where cs.sql_id like nvl('&1','%')
;
@inc/input_vars_undef;