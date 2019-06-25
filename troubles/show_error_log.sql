col column_name for a15;
col data_type   for a15;
col def         for a25;
select column_name, data_type
     , case 
           when data_type='NUMBER' then
              data_type
              || '('
              || decode(data_precision,null,'38',data_precision)
              || ','
              || decode(data_scale,null,'*',data_scale)
              || ')'
           when data_type in ('CHAR','VARCHAR2','NCHAR','NVARCHAR2') then
              data_type
              || '('||char_col_decl_length||' '
              || decode(char_used,'B','BYTE','C','CHAR',char_used)
              || ')'
       end def
    --,data_length,data_precision,data_scale,nullable,char_col_decl_length,char_used
from all_tab_columns c
where 1=1
and table_name='ERROR_LOG'
and owner='SYS'
/

col username   for a15;
col ip_addr    for a15;
col msg        for a40;
col SQL_TEXT   for a90 trunc;

select * 
from error_log;
col ip_addr    clear;
col msg        clear;
col SQL_TEXT   clear;