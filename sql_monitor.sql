/* Real-time sql monitoring report.
   Input params: 
      sql_id,sid,start,end,level.
   Example: 
      @sql_monitor sql_id=4pu1cm9xmc35t,sid=999,start=sysdate-10/24/60,level=typical,end=sysdate-5/24/60
   
   Level of detail for the report, either 'NONE', 'BASIC', 'TYPICAL' or 'ALL'. Default assumes 'TYPICAL'. Their meanings are explained below.
   In addition, individual report sections can also be enabled or disabled by using a +/- section_name. Several sections are defined:
      'XPLAN'- Show explain plan; ON by default
      'PLAN'- Show plan monitoring statistics; ON by default
      'SESSIONS'- Show session details. Applies only to parallel queries; ON by default
      'INSTANCE'- Show instance details. Applies only to parallel and cross instance; ON by default
      'PARALLEL'- An umbrella parameter for specifying sessions+instance details
      'ACTIVITY' - Show activity summary at global level, plan line level and session or instance level (if applicable); ON by default
      'BINDS' - Show bind information when available; ON by default
      'METRICS' - Show metric data (CPU, IOs, ...) over time; ON by default
      'ACTIVITY_HISTOGRAM' - Show an histogram of the overall query activity; ON by default
      'PLAN_HISTOGRAM' - Show activity histogram at plan line level; OFF by default
      'OTHER' - Other info; ON by default
   In addition, SQL text can be specified at different levels:
      +/-SQL_TEXT - SQL text in report
      +/-SQL_FULLTEXT - full SQL text
*/
col p_sql_id new_val p_sql_id noprint
col p_sid    new_val p_sid    noprint
col p_start  new_val p_start  noprint
col p_end    new_val p_end    noprint
col p_level  new_val p_level  noprint
-- parse params:
with 
   t as ( 
         select '&1' s from dual
   )
  ,params as (
         select 
            s                                            params
           ,regexp_substr(s,'sql_id=([^,]+)' ,1,1,'i',1) p_sql_id
           ,regexp_substr(s,'sid=([^,]+)'    ,1,1,'i',1) p_sid
           ,regexp_substr(s,'start=([^,]+)'  ,1,1,'i',1) p_start
           ,regexp_substr(s,'end=([^,]+)'    ,1,1,'i',1) p_end
           ,regexp_substr(s,'level=([^,]+)'  ,1,1,'i',1) p_level
         from t
   )
select params               params
      ,p_sql_id             p_sql_id
      ,nvl(p_sid   ,'null') p_sid
      ,nvl(p_start ,'null') p_start
      ,nvl(p_end   ,'null') p_end
      ,nvl(p_level ,'ALL' ) p_level
from params;
----------------------
col p_sql_id clear
col p_sid    clear
col p_start  clear
col p_end    clear
col p_level  clear
----------------------  
select 
dbms_sqltune.report_sql_monitor(
   sql_id                    => '&p_sql_id',
   session_id                => &p_sid,
   start_time_filter         => &p_start,
   end_time_filter           => &p_end,
   report_level              => '&p_level',
--   session_serial            IN NUMBER    DEFAULT  NULL,
--   sql_exec_start            IN DATE      DEFAULT  NULL,
--   sql_exec_id               IN NUMBER    DEFAULT  NULL,
--   inst_id                   IN NUMBER    DEFAULT  NULL,
--   instance_id_filter        IN NUMBER    DEFAULT  NULL,
--   parallel_filter           IN VARCHAR2  DEFAULT  NULL,
--   plan_line_filter          IN NUMBER    DEFAULT  NULL,
--   event_detail              IN VARCHAR2  DEFAULT  'YES',
--   bucket_max_count          IN NUMBER    DEFAULT  128,
--   bucket_interval           IN NUMBER    DEFAULT  NULL,
--   base_path                 IN VARCHAR2  DEFAULT  NULL,
--   last_refresh_time         IN DATE      DEFAULT  NULL,
   --sql_plan_hash_value       IN NUMBER    DEFAULT  NULL,
   type                      => 'TEXT'
   )
from dual;
