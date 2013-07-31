col if_wrh new_val _if_wrh noprint;
col target new_val _target noprint;
select
     decode(count(*),1,''                ,'--'              ) as if_wrh 
    ,decode(count(*),1,'SYS.WRH$_SQLTEXT','DBA_HIST_SQLTEXT') as target
from all_objects o where o.owner='SYS' and object_name='WRH$_SQLTEXT' and object_type='TABLE'
/

col awr_sql_text format a150;
col sql_id       format a13;
select * 
from (
     select
               dbid          as dbid
              ,sql_id        as sql_id
     &_IF_WRH ,snap_id       as snap_id
     &_IF_WRH ,ref_count     as ref_count
              ,sql_text      as awr_sql_text
              ,command_type  as command_type
     from 
          &_target
     where upper(sql_text) like upper('&1')
     order by 
               dbid
     &_IF_WRH ,SNAP_ID desc
) tmp
where rownum<=20
/

undef _if_wrh _target
col awr_sql_text clear;