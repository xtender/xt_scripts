create or replace package xt_ash is

  /**
   * Author  : Sayan Malakshinov http://orasql.org
   * Purpose : Save data of the ASH and Real-time sql monitor 
   */
  
  /** Save previous C_INTERVAL minutes: */
  C_INTERVAL constant int := 60; -- minutes
  /** Job name: */
  C_JOB_NAME constant varchar2(30):='XT_SNAP_ASH_JOB';
  
  
  /** Enable snapping: */
  procedure enable;
  
  /** Disable snapping: */
  
  procedure disable;
  /** Get status: */
  
  function status return varchar2;
  /** Snap data: */
  
  procedure snap;
  
  /** Schedule snapping job: */
  procedure schedule( 
      p_start timestamp with time zone
     ,p_end   timestamp with time zone
  );
  /** Drop scheduler job: */
  procedure drop_job;
  
  procedure truncate_data;
end xt_ash;
/
create or replace package body xt_ash is

  /** Set param ENABLED to "ON". */
  procedure enable is
  begin
     merge into xt$ash_params p
     using (select 'ENABLED' param, 'ON' value from dual) new_val
     on(p.param = new_val.param)
     when matched then
        update set p.value=new_val.value
     when not matched then
        insert(param,value)
        values(new_val.param,new_val.value);
     commit;
  end;
  
  /** Set param ENABLED to "OFF". */
  procedure disable is
  begin
     merge into xt$ash_params p
     using (select 'ENABLED' param, 'OFF' value from dual) new_val
     on(p.param = new_val.param)
     when matched then
        update set p.value=new_val.value
     when not matched then
        insert(param,value)
        values(new_val.param,new_val.value);
     commit;
  end;
  
  /** internal function to check whether xt_ash is enabled or not. */
  function is_enabled return boolean is
     res int;
  begin
     select count(*) into res from xt$ash_params p where param='ENABLED' and value='ON';
     return case res when 1 then true else false end;
  end is_enabled;
  
  /** Return xt_ash status. */
  function status return varchar2 is
  begin
     if is_enabled() 
        then return 'ENABLED';
        else return 'DISABLED';
     end if;
  end status;

  procedure snap_ash( p_prev_time timestamp) is
     l_last_sample_time timestamp;
  begin
     -- start time:
     select greatest(nvl(max(sample_time),p_prev_time),p_prev_time)
       into l_last_sample_time
     from xt$active_session_history xh
     where xh.sample_time > p_prev_time;

     -- save ash:
     insert into xt$active_session_history
     select * from v$active_session_history h
     where h.sample_time > l_last_sample_time;
     
     -- save SQLs:
     insert into xt$sql_text
     with v_sqlids as (
          select sql_id
          from (
               select distinct sql_id 
               from (select sql_id           as s1
                          , top_level_sql_id as s2
                     from xt$active_session_history xh
                     where xh.sample_time > l_last_sample_time
                    ) v1
               unpivot (
                 sql_id for stype in (s1,s2)
               )
          ) vs
          where 
               vs.sql_id is not null
           and not exists (select null from xt$sql_text xs where xs.sql_id=vs.sql_id)
     )
     select a.sql_id,a.sql_fulltext
     from v_sqlids,v$sqlarea a
     where v_sqlids.sql_id = a.sql_id;
  end snap_ash;

  /** Internal procedure: snap v$sql_monitor */
  procedure i_snap_sql_monitor(p_last_refresh_time date) is
  begin
     merge into xt$sql_monitor xm
     using (select m.* 
            from v$sql_monitor m 
            where m.LAST_REFRESH_TIME > p_last_refresh_time
           ) sm
     on (    xm.SQL_ID       = sm.SQL_ID     
         and xm.KEY          = sm.KEY        
         and xm.SQL_EXEC_ID  = sm.SQL_EXEC_ID
         and xm.SID          = sm.SID        
        )
     when matched then update
        set
            xm.status                    = sm.status                       ,
            xm.user#                     = sm.user#                        ,
            xm.username                  = sm.username                     ,
            xm.module                    = sm.module                       ,
            xm.action                    = sm.action                       ,
            xm.service_name              = sm.service_name                 ,
            xm.client_identifier         = sm.client_identifier            ,
            xm.client_info               = sm.client_info                  ,
            xm.program                   = sm.program                      ,
            xm.plsql_entry_object_id     = sm.plsql_entry_object_id        ,
            xm.plsql_entry_subprogram_id = sm.plsql_entry_subprogram_id    ,
            xm.plsql_object_id           = sm.plsql_object_id              ,
            xm.plsql_subprogram_id       = sm.plsql_subprogram_id          ,
            xm.first_refresh_time        = sm.first_refresh_time           ,
            xm.last_refresh_time         = sm.last_refresh_time            ,
            xm.refresh_count             = sm.refresh_count                ,
            xm.process_name              = sm.process_name                 ,
            xm.sql_text                  = sm.sql_text                     ,
            xm.is_full_sqltext           = sm.is_full_sqltext              ,
            xm.sql_exec_start            = sm.sql_exec_start               ,
            xm.sql_plan_hash_value       = sm.sql_plan_hash_value          ,
            xm.exact_matching_signature  = sm.exact_matching_signature     ,
            xm.force_matching_signature  = sm.force_matching_signature     ,
            xm.sql_child_address         = sm.sql_child_address            ,
            xm.session_serial#           = sm.session_serial#              ,
            xm.px_is_cross_instance      = sm.px_is_cross_instance         ,
            xm.px_maxdop                 = sm.px_maxdop                    ,
            xm.px_maxdop_instances       = sm.px_maxdop_instances          ,
            xm.px_servers_requested      = sm.px_servers_requested         ,
            xm.px_servers_allocated      = sm.px_servers_allocated         ,
            xm.px_server#                = sm.px_server#                   ,
            xm.px_server_group           = sm.px_server_group              ,
            xm.px_server_set             = sm.px_server_set                ,
            xm.px_qcinst_id              = sm.px_qcinst_id                 ,
            xm.px_qcsid                  = sm.px_qcsid                     ,
            xm.error_number              = sm.error_number                 ,
            xm.error_facility            = sm.error_facility               ,
            xm.error_message             = sm.error_message                ,
            xm.binds_xml                 = sm.binds_xml                    ,
            xm.other_xml                 = sm.other_xml                    ,
            xm.elapsed_time              = sm.elapsed_time                 ,
            xm.queuing_time              = sm.queuing_time                 ,
            xm.cpu_time                  = sm.cpu_time                     ,
            xm.fetches                   = sm.fetches                      ,
            xm.buffer_gets               = sm.buffer_gets                  ,
            xm.disk_reads                = sm.disk_reads                   ,
            xm.direct_writes             = sm.direct_writes                ,
            xm.io_interconnect_bytes     = sm.io_interconnect_bytes        ,
            xm.physical_read_requests    = sm.physical_read_requests       ,
            xm.physical_read_bytes       = sm.physical_read_bytes          ,
            xm.physical_write_requests   = sm.physical_write_requests      ,
            xm.physical_write_bytes      = sm.physical_write_bytes         ,
            xm.application_wait_time     = sm.application_wait_time        ,
            xm.concurrency_wait_time     = sm.concurrency_wait_time        ,
            xm.cluster_wait_time         = sm.cluster_wait_time            ,
            xm.user_io_wait_time         = sm.user_io_wait_time            ,
            xm.plsql_exec_time           = sm.plsql_exec_time              ,
            xm.java_exec_time            = sm.java_exec_time               
     when not matched then 
        insert (
            xm.key,                    xm.status,                   xm.user#,                    xm.username, 
            xm.module,                 xm.action,                   xm.service_name,             xm.client_identifier, 
            xm.client_info,            xm.program,                  xm.plsql_entry_object_id,    xm.plsql_entry_subprogram_id, 
            xm.plsql_object_id,        xm.plsql_subprogram_id,      xm.first_refresh_time,       xm.last_refresh_time, 
            xm.refresh_count,          xm.sid,                      xm.process_name,             xm.sql_id, 
            xm.sql_text,               xm.is_full_sqltext,          xm.sql_exec_start,           xm.sql_exec_id, 
            xm.sql_plan_hash_value,    xm.exact_matching_signature, xm.force_matching_signature, xm.sql_child_address, 
            xm.session_serial#,        xm.px_is_cross_instance,     xm.px_maxdop,                xm.px_maxdop_instances, 
            xm.px_servers_requested,   xm.px_servers_allocated,     xm.px_server#,               xm.px_server_group, 
            xm.px_server_set,          xm.px_qcinst_id,             xm.px_qcsid,                 xm.error_number, 
            xm.error_facility,         xm.error_message,            xm.binds_xml,                xm.other_xml, 
            xm.elapsed_time,           xm.queuing_time,             xm.cpu_time,                 xm.fetches, 
            xm.buffer_gets,            xm.disk_reads,               xm.direct_writes,            xm.io_interconnect_bytes, 
            xm.physical_read_requests, xm.physical_read_bytes,      xm.physical_write_requests,  xm.physical_write_bytes, 
            xm.application_wait_time,  xm.concurrency_wait_time,    xm.cluster_wait_time,        xm.user_io_wait_time, 
            xm.plsql_exec_time,        xm.java_exec_time            
        )
        values (
            sm.key,                    sm.status,                   sm.user#,                    sm.username, 
            sm.module,                 sm.action,                   sm.service_name,             sm.client_identifier, 
            sm.client_info,            sm.program,                  sm.plsql_entry_object_id,    sm.plsql_entry_subprogram_id, 
            sm.plsql_object_id,        sm.plsql_subprogram_id,      sm.first_refresh_time,       sm.last_refresh_time, 
            sm.refresh_count,          sm.sid,                      sm.process_name,             sm.sql_id, 
            sm.sql_text,               sm.is_full_sqltext,          sm.sql_exec_start,           sm.sql_exec_id, 
            sm.sql_plan_hash_value,    sm.exact_matching_signature, sm.force_matching_signature, sm.sql_child_address, 
            sm.session_serial#,        sm.px_is_cross_instance,     sm.px_maxdop,                sm.px_maxdop_instances, 
            sm.px_servers_requested,   sm.px_servers_allocated,     sm.px_server#,               sm.px_server_group, 
            sm.px_server_set,          sm.px_qcinst_id,             sm.px_qcsid,                 sm.error_number, 
            sm.error_facility,         sm.error_message,            sm.binds_xml,                sm.other_xml, 
            sm.elapsed_time,           sm.queuing_time,             sm.cpu_time,                 sm.fetches, 
            sm.buffer_gets,            sm.disk_reads,               sm.direct_writes,            sm.io_interconnect_bytes, 
            sm.physical_read_requests, sm.physical_read_bytes,      sm.physical_write_requests,  sm.physical_write_bytes, 
            sm.application_wait_time,  sm.concurrency_wait_time,    sm.cluster_wait_time,        sm.user_io_wait_time, 
            sm.plsql_exec_time,        sm.java_exec_time            
        );
  end i_snap_sql_monitor;

  /** Internal procedure: snap v$sql_monitor */
  procedure i_snap_sql_plan_monitor(p_last_refresh_time date) is
  begin
     merge into xt$sql_plan_monitor xpm
     using (select pm.* 
            from v$sql_plan_monitor pm 
            where pm.LAST_REFRESH_TIME > p_last_refresh_time
           ) spm
     on (    xpm.SQL_ID       = spm.SQL_ID     
         and xpm.KEY          = spm.KEY        
         and xpm.SQL_EXEC_ID  = spm.SQL_EXEC_ID
         and xpm.SID          = spm.SID        
        )
     when matched then update
        set
            xpm.status                  = spm.status                    ,
            xpm.first_refresh_time      = spm.first_refresh_time        ,
            xpm.last_refresh_time       = spm.last_refresh_time         ,
            xpm.first_change_time       = spm.first_change_time         ,
            xpm.last_change_time        = spm.last_change_time          ,
            xpm.refresh_count           = spm.refresh_count             ,
            xpm.process_name            = spm.process_name              ,
            xpm.sql_exec_start          = spm.sql_exec_start            ,
            xpm.sql_plan_hash_value     = spm.sql_plan_hash_value       ,
            xpm.sql_child_address       = spm.sql_child_address         ,
            xpm.plan_parent_id          = spm.plan_parent_id            ,
            xpm.plan_line_id            = spm.plan_line_id              ,
            xpm.plan_operation          = spm.plan_operation            ,
            xpm.plan_options            = spm.plan_options              ,
            xpm.plan_object_owner       = spm.plan_object_owner         ,
            xpm.plan_object_name        = spm.plan_object_name          ,
            xpm.plan_object_type        = spm.plan_object_type          ,
            xpm.plan_depth              = spm.plan_depth                ,
            xpm.plan_position           = spm.plan_position             ,
            xpm.plan_cost               = spm.plan_cost                 ,
            xpm.plan_cardinality        = spm.plan_cardinality          ,
            xpm.plan_bytes              = spm.plan_bytes                ,
            xpm.plan_time               = spm.plan_time                 ,
            xpm.plan_partition_start    = spm.plan_partition_start      ,
            xpm.plan_partition_stop     = spm.plan_partition_stop       ,
            xpm.plan_cpu_cost           = spm.plan_cpu_cost             ,
            xpm.plan_io_cost            = spm.plan_io_cost              ,
            xpm.plan_temp_space         = spm.plan_temp_space           ,
            xpm.starts                  = spm.starts                    ,
            xpm.output_rows             = spm.output_rows               ,
            xpm.io_interconnect_bytes   = spm.io_interconnect_bytes     ,
            xpm.physical_read_requests  = spm.physical_read_requests    ,
            xpm.physical_read_bytes     = spm.physical_read_bytes       ,
            xpm.physical_write_requests = spm.physical_write_requests   ,
            xpm.physical_write_bytes    = spm.physical_write_bytes      ,
            xpm.workarea_mem            = spm.workarea_mem              ,
            xpm.workarea_max_mem        = spm.workarea_max_mem          ,
            xpm.workarea_tempseg        = spm.workarea_tempseg          ,
            xpm.workarea_max_tempseg    = spm.workarea_max_tempseg      
     when not matched then 
        insert (
            xpm.status                 , xpm.first_refresh_time      , xpm.last_refresh_time     , xpm.first_change_time      ,
            xpm.last_change_time       , xpm.refresh_count           , xpm.process_name          , xpm.sql_exec_start         ,
            xpm.sql_plan_hash_value    , xpm.sql_child_address       , xpm.plan_parent_id        , xpm.plan_line_id           ,
            xpm.plan_operation         , xpm.plan_options            , xpm.plan_object_owner     , xpm.plan_object_name       ,
            xpm.plan_object_type       , xpm.plan_depth              , xpm.plan_position         , xpm.plan_cost              ,
            xpm.plan_cardinality       , xpm.plan_bytes              , xpm.plan_time             , xpm.plan_partition_start   ,
            xpm.plan_partition_stop    , xpm.plan_cpu_cost           , xpm.plan_io_cost          , xpm.plan_temp_space        ,
            xpm.starts                 , xpm.output_rows             , xpm.io_interconnect_bytes , xpm.physical_read_requests ,
            xpm.physical_read_bytes    , xpm.physical_write_requests , xpm.physical_write_bytes  , xpm.workarea_mem           ,
            xpm.workarea_max_mem       , xpm.workarea_tempseg        , xpm.workarea_max_tempseg  
        )
        values (
            spm.status                 , spm.first_refresh_time      , spm.last_refresh_time     , spm.first_change_time      ,
            spm.last_change_time       , spm.refresh_count           , spm.process_name          , spm.sql_exec_start         ,
            spm.sql_plan_hash_value    , spm.sql_child_address       , spm.plan_parent_id        , spm.plan_line_id           ,
            spm.plan_operation         , spm.plan_options            , spm.plan_object_owner     , spm.plan_object_name       ,
            spm.plan_object_type       , spm.plan_depth              , spm.plan_position         , spm.plan_cost              ,
            spm.plan_cardinality       , spm.plan_bytes              , spm.plan_time             , spm.plan_partition_start   ,
            spm.plan_partition_stop    , spm.plan_cpu_cost           , spm.plan_io_cost          , spm.plan_temp_space        ,
            spm.starts                 , spm.output_rows             , spm.io_interconnect_bytes , spm.physical_read_requests ,
            spm.physical_read_bytes    , spm.physical_write_requests , spm.physical_write_bytes  , spm.workarea_mem           ,
            spm.workarea_max_mem       , spm.workarea_tempseg        , spm.workarea_max_tempseg  
        );
  end i_snap_sql_plan_monitor;

  /** SNAP Real-Time sql monitor. */
  procedure snap_rtsm( p_prev_time timestamp) is
     l_prev_time         date:=cast(p_prev_time as date);
     l_last_refresh_time date;
  begin
     -- start date:
     select greatest(nvl(max(last_refresh_time),l_prev_time),l_prev_time)
       into l_last_refresh_time
     from xt$sql_monitor xm
     where xm.last_refresh_time > l_prev_time;
  
     i_snap_sql_monitor     (l_last_refresh_time);
     i_snap_sql_plan_monitor(l_last_refresh_time);
  end snap_rtsm;
  
  /** Main SNAP function. */
  procedure snap is
     l_time_curr timestamp := systimestamp;
     l_time_prev timestamp := l_time_curr - numtodsinterval(XT_ASH.C_INTERVAL,'minute');
  begin
     if xt_ash.is_enabled then
        snap_ash ( l_time_prev );
        snap_rtsm( l_time_prev );
        commit;
     end if;
  end snap;
  
  /** Schedule snapping job: */
  procedure schedule( 
      p_start timestamp with time zone
     ,p_end   timestamp with time zone
  ) is
    e_job_exists exception;
    pragma exception_init(e_job_exists, -27477);
  begin
     -- create job:
     begin
        dbms_scheduler.create_job (
            job_name        => C_JOB_NAME
           ,job_type        => 'STORED_PROCEDURE'
           ,job_action      => 'XT_ASH.SNAP'
           ,start_date      => p_start
           ,repeat_interval => 'freq=hourly; byminute=0; bysecond=0'
           ,end_date        => p_end
           ,enabled         => true
           ,auto_drop       => false
        );
     exception
        when e_job_exists then
           dbms_scheduler.set_attribute(
              name      => C_JOB_NAME
             ,attribute => 'start_date'
             ,value     => p_start
           );
           dbms_scheduler.set_attribute(
              name      => C_JOB_NAME
             ,attribute => 'end_date'
             ,value     => p_end
           );
     end;
     -- end create job;
     
     -- set logging level:
     dbms_scheduler.set_attribute(
              name      => C_JOB_NAME
             ,attribute => 'logging_level'
             ,value     => dbms_scheduler.logging_failed_runs
     );
     -- enable:
     dbms_scheduler.enable(C_JOB_NAME);
     xt_ash.enable;
  end schedule;
  
  procedure drop_job is
  begin
     dbms_scheduler.drop_job(C_JOB_NAME);
  end drop_job;
  
  procedure truncate_data is
  begin
     execute immediate 'truncate table xt$active_session_history';
     execute immediate 'truncate table xt$sql_text';
     execute immediate 'truncate table xt$sql_monitor';
     execute immediate 'truncate table xt$sql_plan_monitor';
     execute immediate 'truncate table xt$ash_params';
  end;
  
end xt_ash;
/
