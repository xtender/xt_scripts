col username   for a15;
col ip_addr    for a15;
col msg        for a40;
col SQL_TEXT   for a90 trunc;

select * 
from error_log;
col ip_addr    clear;
col msg        clear;
col SQL_TEXT   clear;