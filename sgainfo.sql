break -
on name           -
on sga_mem        skip page -
on sgainfo_name   -
on sgainfo_mem    -
on sgastat_name   -
on sgastat_bytes  -
  skip 2;

with 
 info as (
     select 
        i.*
       ,sum(sgainfo_mem) over(partition by jname) sgainfo_total
     from (
        select
           case 
              when inf.name='Fixed SGA Size'            then 'Fixed Size'
              when inf.name='Redo Buffers'              then 'Redo Buffers'
              when inf.name='Buffer Cache Size'         then 'Database Buffers'
              when inf.name='In-Memory Area Size'       then 'In-memory Area'

              when inf.name='Java Pool Size'            then 'Variable Size'
              when inf.name='Shared Pool Size'          then 'Variable Size'
              when inf.name='Large Pool Size'           then 'Variable Size'
              when inf.name='Streams Pool Size'         then 'Variable Size'
              when inf.name='Free SGA Memory Available' then 'Variable Size'
              else '-'
           end            as jname
          ,name           as sgainfo_name
          ,inf.bytes      as sgainfo_mem
       from v$sgainfo inf
     ) i
),
 stat as (
     select 
        v.*
       ,sum(sgastat_bytes)over(partition by sname) sgastat_total
     from (
         select
           decode(
              nvl(pool,name)
             ,'buffer_cache'    ,'Buffer Cache Size'
             ,'shared_io_pool'  ,'Buffer Cache Size'
             ,'fixed_sga'       ,'Fixed SGA Size'
             ,'log_buffer'      ,'Redo Buffers'
             ,'java pool'       ,'Java Pool Size'
             ,'large pool'      ,'Large Pool Size'
             ,'shared pool'     ,'Shared Pool Size'
             ,'streams pool'    ,'Streams Pool Size'
             ,'----'
           ) sname
          ,nvl(pool,name) sgastat_name
          ,sum(bytes) sgastat_bytes
        from v$sgastat sta
        group by nvl(pool,name)
       ) v
 )
,mdc as (
     select *
     from (
        select
           case 
              when m.component='shared pool'                then 'shared pool'
              when m.component='large pool'                 then 'large pool'
              when m.component='java pool'                  then 'java pool'
              when m.component='streams pool'               then 'Streams Pool Size'
              when m.component='SGA Target'                 then '??? SGA Target'
              when lower(m.component) like '%buffer cache%' then 'buffer_cache'
              when m.component='Shared IO Pool'             then 'shared_io_pool'
              when m.component='Data Transfer Cache'        then 'Data Transfer Cache Size'
              when lower(m.component) like '%in%memory%'    then 'In-Memory Area Size'
              when m.component='PGA Target'                 then '??? PGA Target'
           end mdc_info
          ,m.component
          ,m.current_size
          ,m.user_specified_size
          ,m.last_oper_type
        from v$memory_dynamic_components m
     )
)
select
   nvl(sga.name,'[Other]') name
  ,sga.value               sga_mem       
--  ,info.sgainfo_total      sgainfo_total
  ,info.sgainfo_name       sgainfo_name
  ,info.sgainfo_mem        sgainfo_mem
--  ,stat.sgastat_total      sgastat_total
  ,stat.sgastat_name       sgastat_name
  ,stat.sgastat_bytes      sgastat_bytes
  ,mdc.component           component
  ,mdc.current_size        current_size
from 
   v$sga sga
   full join info
        on info.jname=sga.name
   full join stat
        on stat.sname=info.sgainfo_name
    join mdc
        on mdc.mdc_info in (sgainfo_name,sgastat_name)
order by name,sgainfo_name,sgastat_name,component
/
