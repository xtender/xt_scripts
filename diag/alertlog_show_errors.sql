accept beg prompt "Begin timestamp: ";
accept end prompt "End timestamp[systimestamp]: " default "systimestamp";
col originating_timestamp for a33;
col message_text          for a200;

select
   to_char(originating_timestamp,'yyyy-mm-dd hh24:mi:ssxff TZR') originating_timestamp
  ,message_text
  --,inst_id
  ,component_id
  ,host_id
  ,host_address
  ,message_type
  ,message_level
  ,message_group
  ,client_id
  ,module_id
  ,process_id
  ,user_id
  ,detailed_location
  ,problem_key
from --sys.x$dbgalertext
     v$diag_alert_ext
where 
   originating_timestamp between timestamp'&beg' and &end
and ( problem_key is not null
      or message_text like '%ORA-%'
      or message_text like '%WARNING%'
      or message_text like '%FATAL%'
    )
/
col originating_timestamp clear;
col message_text          clear;
