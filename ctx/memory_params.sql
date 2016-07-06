col PAR_NAME        for A40;
col PAR_VALUE       for a30;
col DISPLAY_VALUE   for a20;
select   PAR_NAME
        ,PAR_VALUE
        ,lpad(to_char(to_number(PAR_VALUE,'99999999999999999999999999')/1024/1024,'TM9'),17)||' MB' as DISPLAY_VALUE
from ctx_parameters
where PAR_NAME like '%MEMORY%'
order by 1;

col PAR_NAME        clear;
col PAR_VALUE       clear;
col DISPLAY_VALUE   clear;