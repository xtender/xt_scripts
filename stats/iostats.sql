@inc/input_vars_init
@inc/colors
prompt ===============================================================
prompt |   &_C_BOLD.&_C_RED.IO STATS for tablespace_name like nvl(upper('&1'),'%') &_C_RESET.|
prompt ===============================================================

col tablespace      format a30;
col datafile        format a50;
col FILETYPE_NAME   format a20;

select  ts.name             tablespace
       ,df.name              datafile
       ,io.filetype_name
       ,io.filetype_id
       ,io.file_no
       --,i.small_read_servicetime,i.small_write_servicetime
       ,case
           when small_read_servicetime=0 then 0
           else small_read_megabytes/(small_read_servicetime/1000)
        end "sb reads MB/sec"
       ,case 
           when small_write_servicetime=0 then 0
           else small_write_megabytes/(small_write_servicetime/1000)
        end "sb writes MB/sec"
from 
     v$tablespace  ts
    ,v$datafile    df
    ,v$iostat_file io
where 
        df.TS#            = ts.TS#
    and io.file_no        = df.file#
    and io.FILETYPE_NAME != 'Temp File'
    and upper(ts.name) like nvl(upper('&1'),'%')
order by 
        6 desc
       ,7 desc
/
select f.FUNCTION_NAME
      ,f.NUMBER_OF_WAITS
      ,decode(f.NUMBER_OF_WAITS,0,0,f.WAIT_TIME/f.NUMBER_OF_WAITS) per_wait
from V$IOSTAT_FUNCTION f
order by 3 desc
/
col tablespace      clear
col datafile        clear
col FILETYPE_NAME   clear

@inc/input_vars_undef