col param for a25;
col value for a80;

with 
  function get_scheduler_attribute(param in varchar2) return varchar2 is
     res varchar2(100);
  begin
     dbms_scheduler.get_scheduler_attribute(param,res);
     return res;
  end;
current_values(param,value,status) as (
  select 'SCHEDULER_DISABLED'
        ,nvl(get_scheduler_attribute('SCHEDULER_DISABLED'),'FALSE')
        ,case when nvl(upper(get_scheduler_attribute('SCHEDULER_DISABLED')),'FALSE')='FALSE' then 'ok'
              else 'error'
         end
  from dual
  union all
  select name
        ,value 
        ,case when value>0 then 'ok' else 'error' end
  from v$parameter where name like 'job_queue_processes'
  union all
  select 'last_start_date'
        ,to_char(max(j.last_start_date),'yyyy-mm-dd hh24:mi:ss') 
        ,case when max(j.last_start_date)>sysdate-interval'5' minute then 'ok' else 'error' end
  from all_scheduler_jobs j
  where j.owner='TMDDBA'
  and job_name like 'DR$%'
  union all
  select index_name
        ,status||'/'||i.DOMIDX_STATUS||'/'||i.domidx_opstatus 
        ,'error'
  from all_indexes i 
  where owner='TMDDBA'
    and index_type='DOMAIN'
    and (status!='VALID'
       or domidx_status!='VALID'
       or domidx_opstatus!='VALID')
)
select * 
from current_values
/