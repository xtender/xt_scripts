with
   function raw_to_date(i_raw raw)
   return date
   as
      m_n date;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
   function val(p_datatype varchar2,p_value varchar2) 
   return varchar2
   is
     res varchar2(4000);
   begin
     if p_datatype is null then return null; end if;
      res := case
           when p_datatype like 'VARCHAR2%'  then (p_value)
           when p_datatype like 'DATE'       then (p_value)
                --to_char(raw_to_date(hextoraw(p_value)),'yyyy-mm-dd hh24:mi:ss')
           when p_datatype like 'TIMESTAMP' then to_char(raw_to_date(hextoraw(p_value)),'yyyy-mm-dd hh24:mi:ss')
           when p_datatype like 'NUMBER%'    then (p_value)
           else p_datatype||':'||p_value
        end;
      return nvl(res,'NULL');
   exception when others then return p_datatype||':'||p_value;
   end;
function get_key(key in varchar2, num int) return number is 
  str  varchar2(100):= regexp_substr(key,'[^#]+',1,num);
  fstr varchar2(100):= '0'||str;
  frmt varchar2(100):= translate(fstr,'.0123456789','d9999999999');
  fnls varchar2(100):=q'{NLS_NUMERIC_CHARACTERS = '.,'}';
begin
  return to_number(fstr DEFAULT null ON CONVERSION ERROR,frmt,fnls);
end;
reps as (
  select 
     report_id
    ,period_start_time
    ,key1                      as sql_id
    ,to_number(key2)           as sql_exec_id
    ,key3                      as sql_exec_start
    ,get_key(key4,1)           as duration
    ,get_key(key4,2)/1e6       as ela_sec
    ,get_key(key4,3)/1e6       as cpu_sec
    ,get_key(key4,4)           as read_reqs
    ,get_key(key4,5)/1024/1024 as read_mb
    ,report_summary
    ,key4
    ,r.dbid, r.instance_number as inst, r.snap_id
  from dba_hist_reports r
  where 1=1
    and r.component_name = 'sqlmonitor'
    and r.key1        = '&1'
  order by r.snap_id desc, r.period_start_time desc
  fetch first 20 rows only
)
SELECT-- NO_XML_QUERY_REWRITE
      t.report_id
    , t.period_start_time
    , t.sql_id
    , t.duration
    , t.ela_sec
    , t.cpu_sec
    , t.read_reqs
    , round(t.read_mb,1) read_mb
    --from xml:
    ,x.sql_id        
    ,x.sql_exec_start
    ,x.sql_exec_id   
    ,x.status        
    ,x.plan_hash     
    ,x.dop           
    ,x.px_requested  
    ,x.px_allocated  
    ,round(x.elapsed_time /1e6,4) x_ela_sec
    ,round(x.cpu_time     /1e6,4) x_cpu_sec
    ,round(x.io_time      /1e6,4) x_io_sec
    ,round(x.cl_time      /1e6,4) x_cl_sec
    ,round(x.cc_time      /1e6,4) x_cc_sec
    ,round(x.plsql_time   /1e6,4) x_plsql_sec
    ,round(x.other_time   /1e6,4) x_oth_sec
    ,x.fetches
    ,x.buffer_gets   
    ,x.read_reqs     
    ,x.read_bytes    
    ,x.write_reqs
    ,x.write_bytes
    ,x.ret_bytes
    ,x.other_stats
           ,xxml.b_1_nam            ,xxml.b_1_typ            ,val(xxml.b_1_typ  ,xxml.b_1_val ) as  b_1_val 
           ,xxml.b_2_nam            ,xxml.b_2_typ            ,val(xxml.b_2_typ  ,xxml.b_2_val ) as  b_2_val 
           ,xxml.b_3_nam            ,xxml.b_3_typ            ,val(xxml.b_3_typ  ,xxml.b_3_val ) as  b_3_val 
           ,xxml.b_4_nam            ,xxml.b_4_typ            ,val(xxml.b_4_typ  ,xxml.b_4_val ) as  b_4_val 
           ,xxml.b_5_nam            ,xxml.b_5_typ            ,val(xxml.b_5_typ  ,xxml.b_5_val ) as  b_5_val 
           ,xxml.b_6_nam            ,xxml.b_6_typ            ,val(xxml.b_6_typ  ,xxml.b_6_val ) as  b_6_val 
           ,xxml.b_7_nam            ,xxml.b_7_typ            ,val(xxml.b_7_typ  ,xxml.b_7_val ) as  b_7_val 
           ,xxml.b_8_nam            ,xxml.b_8_typ            ,val(xxml.b_8_typ  ,xxml.b_8_val ) as  b_8_val 
           ,xxml.b_9_nam            ,xxml.b_9_typ            ,val(xxml.b_9_typ  ,xxml.b_9_val ) as  b_9_val 
           ,xxml.b_10_nam           ,xxml.b_10_typ           ,val(xxml.b_10_typ ,xxml.b_10_val) as  b_10_val
           ,xxml.b_11_nam           ,xxml.b_11_typ           ,val(xxml.b_11_typ ,xxml.b_11_val) as  b_11_val
           ,xxml.b_12_nam           ,xxml.b_12_typ           ,val(xxml.b_12_typ ,xxml.b_12_val) as  b_12_val
           ,xxml.b_13_nam           ,xxml.b_13_typ           ,val(xxml.b_13_typ ,xxml.b_13_val) as  b_13_val
           ,xxml.b_14_nam           ,xxml.b_14_typ           ,val(xxml.b_14_typ ,xxml.b_14_val) as  b_14_val
           ,xxml.b_15_nam           ,xxml.b_15_typ           ,val(xxml.b_15_typ ,xxml.b_15_val) as  b_15_val
           ,xxml.b_16_nam           ,xxml.b_16_typ           ,val(xxml.b_16_typ ,xxml.b_16_val) as  b_16_val
           ,xxml.b_17_nam           ,xxml.b_17_typ           ,val(xxml.b_17_typ ,xxml.b_17_val) as  b_17_val
           ,xxml.b_18_nam           ,xxml.b_18_typ           ,val(xxml.b_18_typ ,xxml.b_18_val) as  b_18_val
           ,xxml.b_19_nam           ,xxml.b_19_typ           ,val(xxml.b_19_typ ,xxml.b_19_val) as  b_19_val
           ,xxml.b_20_nam           ,xxml.b_20_typ           ,val(xxml.b_20_typ ,xxml.b_20_val) as  b_20_val
           ,xxml.b_21_nam           ,xxml.b_21_typ           ,val(xxml.b_21_typ ,xxml.b_21_val) as  b_21_val
           ,xxml.b_22_nam           ,xxml.b_22_typ           ,val(xxml.b_22_typ ,xxml.b_22_val) as  b_22_val
           ,xxml.b_23_nam           ,xxml.b_23_typ           ,val(xxml.b_23_typ ,xxml.b_23_val) as  b_23_val
           ,xxml.b_24_nam           ,xxml.b_24_typ           ,val(xxml.b_24_typ ,xxml.b_24_val) as  b_24_val
           ,xxml.b_25_nam           ,xxml.b_25_typ           ,val(xxml.b_25_typ ,xxml.b_25_val) as  b_25_val
           ,xxml.b_26_nam           ,xxml.b_26_typ           ,val(xxml.b_26_typ ,xxml.b_26_val) as  b_26_val
           ,xxml.b_27_nam           ,xxml.b_27_typ           ,val(xxml.b_27_typ ,xxml.b_27_val) as  b_27_val
           ,xxml.b_28_nam           ,xxml.b_28_typ           ,val(xxml.b_28_typ ,xxml.b_28_val) as  b_28_val
           ,xxml.b_29_nam           ,xxml.b_29_typ           ,val(xxml.b_29_typ ,xxml.b_29_val) as  b_29_val
           ,xxml.b_30_nam           ,xxml.b_30_typ           ,val(xxml.b_30_typ ,xxml.b_30_val) as  b_30_val
FROM 
    reps t
    outer apply(
     xmltable('/report_repository_summary/sql'    
       PASSING xmlparse(document t.report_summary)    
       COLUMNS    
        sql_id         varchar2(13) path '@sql_id'     
       ,sql_exec_start varchar2(20) path '@sql_exec_start'    
       ,sql_exec_id    number       path '@sql_exec_id'      
       ,status         varchar2(20) path 'status'    
       ,sql_text       varchar2(80) path 'sql_text'
       ,sid            number       path 'session_id'
       ,serial         number       path 'session_serial'
       ,username       varchar2(30) path 'user'
       ,module         varchar2(64) path 'module'
       ,program        varchar2(64) path 'program'
       ,plan_hash      number       path 'plan_hash'
       ,dop            number       path 'dop'
       ,px_requested   number       path 'px_servers_requested'
       ,px_allocated   number       path 'px_servers_allocated'
       ,duration       number       path 'stats/stat[@name="duration"]'  
       ,elapsed_time   number       path 'stats/stat[@name="elapsed_time"]'  
       ,cpu_time       number       path 'stats/stat[@name="cpu_time"]'  
       ,io_time        number       path 'stats/stat[@name="user_io_wait_time"]'
       ,cl_time        number       path 'stats/stat[@name="cluster_wait_time"]'
       ,cc_time        number       path 'stats/stat[@name="concurrency_wait_time"]'
       ,plsql_time     number       path 'stats/stat[@name="plsql_exec_time"]'
       ,other_time     number       path 'stats/stat[@name="other_wait_time"]'
       ,fetches        number       path 'stats/stat[@name="user_fetch_count"]'
       ,buffer_gets    number       path 'stats/stat[@name="buffer_gets"]'
       ,read_reqs      number       path 'stats/stat[@name="read_reqs"]'
       ,read_bytes     number       path 'stats/stat[@name="read_bytes"]'
       ,write_reqs     number       path 'stats/stat[@name="write_reqs"]'
       ,write_bytes    number       path 'stats/stat[@name="write_bytes"]'
       ,ret_bytes      number       path 'stats/stat[@name="ret_bytes"]'
       ,other_stats xmltype path 'stats/*[not(@name=("duration"  ,"elapsed_time"  ,"cpu_time"  ,"user_io_wait_time"
            ,"cluster_wait_time","concurrency_wait_time","plsql_exec_time","other_wait_time"
            ,"user_fetch_count","buffer_gets","read_reqs"
            ,"read_bytes","write_reqs","write_bytes","ret_bytes"))]'
     )) x 
    outer apply(
        xmltable('/report/sql_monitor_report/binds'
         PASSING DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL_XML(RID => t.report_id) 
         COLUMNS
            --binds xmltype path './*'
            b_1_nam varchar2(30) path './bind[1]/@name'       ,b_11_nam varchar2(30) path './bind[11]/@name'      ,b_21_nam varchar2(30) path './bind[21]/@name'
           ,b_1_typ varchar2(30) path './bind[1]/@dtystr'     ,b_11_typ varchar2(30) path './bind[11]/@dtystr'    ,b_21_typ varchar2(30) path './bind[21]/@dtystr'
           ,b_1_val varchar2(30) path './bind[1]/text()'      ,b_11_val varchar2(30) path './bind[11]/text()'     ,b_21_val varchar2(30) path './bind[21]/text()'
           ,b_2_nam varchar2(30) path './bind[2]/@name'       ,b_12_nam varchar2(30) path './bind[12]/@name'      ,b_22_nam varchar2(30) path './bind[22]/@name'
           ,b_2_typ varchar2(30) path './bind[2]/@dtystr'     ,b_12_typ varchar2(30) path './bind[12]/@dtystr'    ,b_22_typ varchar2(30) path './bind[22]/@dtystr'
           ,b_2_val varchar2(30) path './bind[2]/text()'      ,b_12_val varchar2(30) path './bind[12]/text()'     ,b_22_val varchar2(30) path './bind[22]/text()'
           ,b_3_nam varchar2(30) path './bind[3]/@name'       ,b_13_nam varchar2(30) path './bind[13]/@name'      ,b_23_nam varchar2(30) path './bind[23]/@name'
           ,b_3_typ varchar2(30) path './bind[3]/@dtystr'     ,b_13_typ varchar2(30) path './bind[13]/@dtystr'    ,b_23_typ varchar2(30) path './bind[23]/@dtystr'
           ,b_3_val varchar2(30) path './bind[3]/text()'      ,b_13_val varchar2(30) path './bind[13]/text()'     ,b_23_val varchar2(30) path './bind[23]/text()'
           ,b_4_nam varchar2(30) path './bind[4]/@name'       ,b_14_nam varchar2(30) path './bind[14]/@name'      ,b_24_nam varchar2(30) path './bind[24]/@name'
           ,b_4_typ varchar2(30) path './bind[4]/@dtystr'     ,b_14_typ varchar2(30) path './bind[14]/@dtystr'    ,b_24_typ varchar2(30) path './bind[24]/@dtystr'
           ,b_4_val varchar2(30) path './bind[4]/text()'      ,b_14_val varchar2(30) path './bind[14]/text()'     ,b_24_val varchar2(30) path './bind[24]/text()'
           ,b_5_nam varchar2(30) path './bind[5]/@name'       ,b_15_nam varchar2(30) path './bind[15]/@name'      ,b_25_nam varchar2(30) path './bind[25]/@name'
           ,b_5_typ varchar2(30) path './bind[5]/@dtystr'     ,b_15_typ varchar2(30) path './bind[15]/@dtystr'    ,b_25_typ varchar2(30) path './bind[25]/@dtystr'
           ,b_5_val varchar2(30) path './bind[5]/text()'      ,b_15_val varchar2(30) path './bind[15]/text()'     ,b_25_val varchar2(30) path './bind[25]/text()'
           ,b_6_nam varchar2(30) path './bind[6]/@name'       ,b_16_nam varchar2(30) path './bind[16]/@name'      ,b_26_nam varchar2(30) path './bind[26]/@name'
           ,b_6_typ varchar2(30) path './bind[6]/@dtystr'     ,b_16_typ varchar2(30) path './bind[16]/@dtystr'    ,b_26_typ varchar2(30) path './bind[26]/@dtystr'
           ,b_6_val varchar2(30) path './bind[6]/text()'      ,b_16_val varchar2(30) path './bind[16]/text()'     ,b_26_val varchar2(30) path './bind[26]/text()'
           ,b_7_nam varchar2(30) path './bind[7]/@name'       ,b_17_nam varchar2(30) path './bind[17]/@name'      ,b_27_nam varchar2(30) path './bind[27]/@name'
           ,b_7_typ varchar2(30) path './bind[7]/@dtystr'     ,b_17_typ varchar2(30) path './bind[17]/@dtystr'    ,b_27_typ varchar2(30) path './bind[27]/@dtystr'
           ,b_7_val varchar2(30) path './bind[7]/text()'      ,b_17_val varchar2(30) path './bind[17]/text()'     ,b_27_val varchar2(30) path './bind[27]/text()'
           ,b_8_nam varchar2(30) path './bind[8]/@name'       ,b_18_nam varchar2(30) path './bind[18]/@name'      ,b_28_nam varchar2(30) path './bind[28]/@name'
           ,b_8_typ varchar2(30) path './bind[8]/@dtystr'     ,b_18_typ varchar2(30) path './bind[18]/@dtystr'    ,b_28_typ varchar2(30) path './bind[28]/@dtystr'
           ,b_8_val varchar2(30) path './bind[8]/text()'      ,b_18_val varchar2(30) path './bind[18]/text()'     ,b_28_val varchar2(30) path './bind[28]/text()'
           ,b_9_nam varchar2(30) path './bind[9]/@name'       ,b_19_nam varchar2(30) path './bind[19]/@name'      ,b_29_nam varchar2(30) path './bind[29]/@name'
           ,b_9_typ varchar2(30) path './bind[9]/@dtystr'     ,b_19_typ varchar2(30) path './bind[19]/@dtystr'    ,b_29_typ varchar2(30) path './bind[29]/@dtystr'
           ,b_9_val varchar2(30) path './bind[9]/text()'      ,b_19_val varchar2(30) path './bind[19]/text()'     ,b_29_val varchar2(30) path './bind[29]/text()'
           ,b_10_nam varchar2(30) path './bind[10]/@name'     ,b_20_nam varchar2(30) path './bind[20]/@name'      ,b_30_nam varchar2(30) path './bind[30]/@name'
           ,b_10_typ varchar2(30) path './bind[10]/@dtystr'   ,b_20_typ varchar2(30) path './bind[20]/@dtystr'    ,b_30_typ varchar2(30) path './bind[30]/@dtystr'
           ,b_10_val varchar2(30) path './bind[10]/text()'    ,b_20_val varchar2(30) path './bind[20]/text()'     ,b_30_val varchar2(30) path './bind[30]/text()'
        )
    ) xxml
;
