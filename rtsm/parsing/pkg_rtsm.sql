create or replace package PKG_RTSM is
  
  -- Hiding helper functions:
  -- function base64_to_blob(p_clob in clob) return blob;
  -- function base64_rtsm_to_xml(p_base64_clob in clob) return clob;
  -- function blob_to_clob(p_blob blob) return clob;
  -- function find_substring_clob(p_clob in clob, p_beg in varchar2, p_end in varchar2, p_including in varchar2 default 'Y') return clob;
  
  function rtsm_html_to_xml(p_blob in blob) return xmltype;
  
  function rtsm_xml_macro_report_info(xmldata xmltype) return varchar2 SQL_MACRO;
  function rtsm_xml_macro_plan_info(xmldata xmltype) return varchar2 SQL_MACRO;
  function rtsm_xml_macro_plan_ops(xmldata xmltype) return varchar2 SQL_MACRO;
  function rtsm_xml_macro_plan_monitor(xmldata xmltype) return varchar2 SQL_MACRO;
  
  PROCEDURE zlib_inflate_blob(
      p_src IN BLOB, 
      p_dst IN OUT BLOB
  ) AS LANGUAGE JAVA 
  NAME 'ZlibHelper.inflate(oracle.sql.BLOB, oracle.sql.BLOB[])';
    
end PKG_RTSM;
/
create or replace package body PKG_RTSM is

  function base64_to_blob(p_clob in clob) return blob
  is
      l_blob        BLOB;
      l_raw         RAW(32767);
      l_buffer      VARCHAR2(32767);
      l_chunk_size  INTEGER := 2400; 
      l_offset      INTEGER := 1;
      l_len         INTEGER;
      v_clob        clob;
  BEGIN
      DBMS_LOB.CREATETEMPORARY(l_blob, TRUE);
        
      v_clob:=REPLACE(REPLACE(REPLACE(p_clob, CHR(10)), CHR(13)), ' ', '');
      l_len := DBMS_LOB.GETLENGTH(v_clob);
        
      WHILE l_offset < l_len LOOP
          l_buffer := DBMS_LOB.SUBSTR(v_clob, l_chunk_size, l_offset);
          IF LENGTH(l_buffer) > 0 THEN
              l_raw := UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(l_buffer));
              DBMS_LOB.WRITEAPPEND(l_blob, UTL_RAW.LENGTH(l_raw), l_raw);
          END IF;
          l_offset := l_offset + l_chunk_size;
      END LOOP;
      RETURN l_blob;
  END;

  function base64_rtsm_to_xml(p_base64_clob in clob) return clob 
  is
      l_compressed_blob BLOB;
      l_decompressed_blob BLOB;
      l_xml_result      CLOB;
      -- temp vars:
      l_dest_offset INTEGER := 1;
      l_src_offset  INTEGER := 1;
      l_lang_ctx    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
      l_warning     INTEGER;  
  BEGIN
      -- 1. Base64 >> BLOB (still ZLIB)
      l_compressed_blob := pkg_rtsm.base64_to_blob(p_base64_clob);
      
      -- 2. BLOB for results
      DBMS_LOB.CREATETEMPORARY(l_decompressed_blob, TRUE);
      
      -- 3. Calling Java inflater, which is working with wbits=15 - standard for Java Inflater.
      PKG_RTSM.zlib_inflate_blob(l_compressed_blob, l_decompressed_blob);
      
      -- 4. BLOB to CLOB (XML)
      DBMS_LOB.CREATETEMPORARY(l_xml_result, TRUE);
      DBMS_LOB.CONVERTTOCLOB(
          dest_lob     => l_xml_result,
          src_blob     => l_decompressed_blob,
          amount       => DBMS_LOB.LOBMAXSIZE,
          dest_offset  => l_dest_offset,
          src_offset   => l_src_offset,
          blob_csid    => DBMS_LOB.DEFAULT_CSID,
          lang_context => l_lang_ctx,
          warning      => l_warning
      );
      
      DBMS_LOB.FREETEMPORARY(l_compressed_blob);
      DBMS_LOB.FREETEMPORARY(l_decompressed_blob);
      
      return l_xml_result;
  END;
  
  function blob_to_clob(p_blob blob) return clob
  is
    l_clob   CLOB;
    dest_offset    INTEGER := 1;
    src_offset     INTEGER := 1;
    lang_context   INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
    warning        INTEGER;
  BEGIN
    DBMS_LOB.CREATETEMPORARY(l_clob, TRUE);
    DBMS_LOB.CONVERTTOCLOB (
      dest_lob     => l_clob,
      src_blob     => p_blob,
      amount       => DBMS_LOB.LOBMAXSIZE,
      dest_offset  => dest_offset,
      src_offset   => src_offset,
      blob_csid    => 871,                       -- 871 = AL32UTF8
      lang_context => lang_context,
      warning      => warning
    );
    return l_clob;
  END blob_to_clob;

  function find_substring_clob(p_clob in clob, p_beg in varchar2, p_end in varchar2, p_including in varchar2 default 'Y') return clob
  is
  begin
    if p_including='Y' then
      return DBMS_LOB.SUBSTR(
             p_clob
            ,INSTR(p_clob, p_end) + LENGTH(p_end) - INSTR(p_clob, p_beg)
            ,INSTR(p_clob, p_beg)
           );
    else
      return DBMS_LOB.SUBSTR(
             p_clob
            ,INSTR(p_clob, p_end) - INSTR(p_clob, p_beg) - LENGTH(p_beg)
            ,INSTR(p_clob, p_beg) + LENGTH(p_beg)
           );
    end if;
  end find_substring_clob;
  
  function rtsm_html_to_xml(p_blob in blob) return xmltype
  is
    v_clob       clob;
    v_prefix     clob;
    v_xml_base64 clob;
    v_xml        clob;
    v_result     clob;
    v_res_xml    xmltype;
  begin
    v_clob       := pkg_rtsm.blob_to_clob(p_blob);
    v_prefix     := pkg_rtsm.find_substring_clob(v_clob,'<report'     ,'</report_id>','Y');
    v_prefix     := replace(v_prefix, 'encode="base64" compress="zlib"', '');
    v_xml_base64 := pkg_rtsm.find_substring_clob(v_clob,'</report_id>','</report>'   ,'N');
    v_xml        := pkg_rtsm.base64_rtsm_to_xml(v_xml_base64);
    v_result := v_prefix || v_xml || '</report>';
    v_res_xml:=xmltype(v_result);
    return v_res_xml;
  end rtsm_html_to_xml;
  
  function rtsm_xml_macro_report_info(xmldata xmltype) return varchar2 SQL_MACRO
  is
  begin
    return q'{
    select   
         rep.db_version           
        ,rep.rp_elapsed_time_sec  
        ,rep.rp_cpu_time_sec      
        ,rep.inst_count           
        ,rep.cpu_cores            
        ,rep.hyperthread          
        ,rep.con_name             
        ,rep.timezone_offset      
        ,rep.exa                  
        --,xd.xml_report_parameters
        ,xd.sql_id         
        ,xd.sql_exec_id    
        ,xd.sql_exec_start 
        ,xd.rep_date       
        ,xd.bucket_count   
        ,xd.interval_start 
        ,xd.interval_end   

        ,xd.xml_target
                  ,xd.inst_id
                  ,xd.sid
                  ,xd.serial
                  ,xd.phv
                  ,xd.phv_full
                  ,xd.platform
                  ,xd.username
                  ,xd.con_id
                  ,xd.program
                  ,xd.module
                  ,xd.action
                  ,xd.service
                  ,xd.client_id
                  ,xd.sql_fulltext
                  ,xd.is_sqltext_full
                  ,xd.status
                  ,xd.refresh_count
                  ,xd.first_refresh_time
                  ,xd.last_refresh_time
                  ,xd.duration
                  ,xd.rmcg
                  ,xd.adaptive_plan
                  ,xd.xml_optimizer_env
                  ,xd.total_cpu_count
                  ,xd.active_instance_count

        ,xd.xml_stats
                  ,xd.elapsed_time
                  ,xd.cpu_time
                  ,xd.plsql_exec_time
                  ,xd.user_io_wait_time
                  ,xd.concurrency_wait_time
                  ,xd.cluster_wait_time
                  ,xd.application_wait_time
                  ,xd.other_wait_time
                  ,xd.user_fetch_count
                  ,xd.buffer_gets
                  ,xd.disk_reads
                  ,xd.read_reqs
                  ,xd.read_bytes
                  ,xd.direct_writes
                  ,xd.write_reqs
                  ,xd.write_bytes
                  ,xd.unc_bytes
                  ,xd.elig_bytes
                  ,xd.ret_bytes
                  ,xd.cell_offload_efficiency
                  ,xd.cell_offload_efficiency2
        ,xd.xml_activity_sampled
        ,xd.xml_binds
        ,xd.xml_activity_detail
        ,xd.xml_plan             as xml_plan_full
           ,plan_op_name
           ,plan_cost
        ,XMLTransform(
           xd.xml_plan
          ,XMLType('<?xml version="1.0" encoding="UTF-8"?>
                    <xsl:stylesheet version="1.0"
                        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                      <xsl:output method="xml" indent="yes"/>
                      <xsl:template match="@* | node()">
                        <xsl:copy>
                          <xsl:apply-templates select="@* | node()" />
                        </xsl:copy>
                      </xsl:template>
                      <xsl:template match="qb_registry"/>
                      <xsl:template match="display_map"/>
                    </xsl:stylesheet>
                    ')
        ) as xml_cleaned_plan
        ,xd.xml_plan_monitor
        ,xd.xml_stattype
        -- reports:
        ,DBMS_REPORT.FORMAT_REPORT(XMLDATA,'TEXT'  ) RTSM_REPORT_TEXT
        ,DBMS_REPORT.FORMAT_REPORT(XMLDATA,'ACTIVE') RTSM_REPORT_ACTIVE
      from 
           xmltable(
             '/report'
             passing XMLDATA
             columns
                sql_monitor_report   xmltype       path 'sql_monitor_report'
               ,db_version           varchar2(20)  path '@db_version'
               ,rp_elapsed_time_sec  number        path'@elapsed_time'
               ,rp_cpu_time_sec      number        path'@cpu_time'
               ,inst_count           number        path'@inst_count'
               ,cpu_cores            number        path'@cpu_cores'
               ,hyperthread          varchar2(1)   path'@hyperthread'
               ,con_name             varchar2(64)  path'@con_name'
               ,timezone_offset      number        path'@timezone_offset'
               ,exa                  varchar2(1)   path'@exa'
            ) rep
           ,xmltable(
             '/sql_monitor_report'
             passing rep.sql_monitor_report
             columns
               --,xml_report_parameters xmltype path 'report_parameters'
                sql_id                varchar2(13) path './report_parameters/sql_id'
               ,sql_exec_id           varchar2(13) path './report_parameters/sql_exec_id'
               ,sql_exec_start        varchar2(13) path './report_parameters/sql_exec_start'
               ,rep_date              varchar2(25) path './@sysdate'
               ,bucket_count          number       path './report_parameters/bucket_count'
               ,interval_start        varchar2(25) path './report_parameters/interval_start'
               ,interval_end          varchar2(25) path './report_parameters/interval_end'
               ,xml_target            xmltype path 'target'
                  ,inst_id                number        path 'target/@instance_id       '
                  ,sid                    number        path 'target/@session_id        '
                  ,serial                 number        path 'target/@session_serial    '
                  ,phv                    number        path 'target/@sql_plan_hash     '
                  ,phv_full               number        path 'target/@sql_full_plan_hash'
                  ,platform               varchar2(200) path 'target/@db_platform_name  '
                  ,username               varchar2(200) path 'target/user               '
                  ,con_id                 number        path 'target/con_id   '
                  ,program                varchar2(200) path 'target/program  '
                  ,module                 varchar2(200) path 'target/module   '
                  ,action                 varchar2(200) path 'target/action   '
                  ,service                varchar2(200) path 'target/service  '
                  ,client_id              varchar2(200) path 'target/client_id'
                  ,sql_fulltext           clob          path 'target/sql_fulltext'
                  ,is_sqltext_full        varchar2(  2) path 'target/sql_fulltext/@is_full'
                  ,status                 varchar2(200) path 'target/status            '
                  ,refresh_count          number        path 'target/refresh_count     '
                  ,first_refresh_time     varchar2(200) path 'target/first_refresh_time'
                  ,last_refresh_time      varchar2(200) path 'target/last_refresh_time '
                  ,duration               number        path 'target/duration          '
                  ,rmcg                   varchar2(200) path 'target/rminfo/@rmcg      '
                  ,adaptive_plan          varchar2(  2) path 'target/adaptive_plan     '
                  ,xml_optimizer_env          xmltype       path 'target/optimizer_env     '
                  ,total_cpu_count        number        path 'target/optimizer_env/param[@name="total_cpu_count"      ]'
                  ,active_instance_count  number        path 'target/optimizer_env/param[@name="active_instance_count"]'
               ,xml_stats             xmltype path 'stats'
                  ,elapsed_time              number        path 'stats[@type="monitor"]/stat[@name="elapsed_time"            ]'
                  ,cpu_time                  number        path 'stats[@type="monitor"]/stat[@name="cpu_time"                ]'
                  ,plsql_exec_time           number        path 'stats[@type="monitor"]/stat[@name="plsql_exec_time"         ]'
                  ,user_io_wait_time         number        path 'stats[@type="monitor"]/stat[@name="user_io_wait_time"       ]'
                  ,concurrency_wait_time     number        path 'stats[@type="monitor"]/stat[@name="concurrency_wait_time"   ]'
                  ,cluster_wait_time         number        path 'stats[@type="monitor"]/stat[@name="cluster_wait_time"       ]'
                  ,application_wait_time     number        path 'stats[@type="monitor"]/stat[@name="application_wait_time"   ]'
                  ,other_wait_time           number        path 'stats[@type="monitor"]/stat[@name="other_wait_time"         ]'
                  ,user_fetch_count          number        path 'stats[@type="monitor"]/stat[@name="user_fetch_count"        ]'
                  ,buffer_gets               number        path 'stats[@type="monitor"]/stat[@name="buffer_gets"             ]'
                  ,disk_reads                number        path 'stats[@type="monitor"]/stat[@name="disk_reads"              ]'
                  ,read_reqs                 number        path 'stats[@type="monitor"]/stat[@name="read_reqs"               ]'
                  ,read_bytes                number        path 'stats[@type="monitor"]/stat[@name="read_bytes"              ]'
                  ,direct_writes             number        path 'stats[@type="monitor"]/stat[@name="direct_writes"           ]'
                  ,write_reqs                number        path 'stats[@type="monitor"]/stat[@name="write_reqs"              ]'
                  ,write_bytes               number        path 'stats[@type="monitor"]/stat[@name="write_bytes"             ]'
                  ,unc_bytes                 number        path 'stats[@type="monitor"]/stat[@name="unc_bytes"               ]'
                  ,elig_bytes                number        path 'stats[@type="monitor"]/stat[@name="elig_bytes"              ]'
                  ,ret_bytes                 number        path 'stats[@type="monitor"]/stat[@name="ret_bytes"               ]'
                  ,cell_offload_efficiency   number        path 'stats[@type="monitor"]/stat[@name="cell_offload_efficiency" ]'
                  ,cell_offload_efficiency2  number        path 'stats[@type="monitor"]/stat[@name="cell_offload_efficiency2"]'

               ,xml_activity_sampled  xmltype path 'activity_sampled'
               ,xml_binds             xmltype path 'binds'
               ,xml_activity_detail   xmltype path 'activity_detail'
               ,xml_plan              xmltype path 'plan'
                  ,plan_op_name  varchar2(200) path 'plan/operation[1]/@name'
                  ,plan_cost     number        path 'plan/operation[1]/cost'
               ,xml_plan_monitor      xmltype path './plan_monitor'
               ,xml_stattype          xmltype path './stattype'
           )(+) xd
  }';
  end;

  function rtsm_xml_macro_plan_info(xmldata xmltype) return varchar2 SQL_MACRO
  is
  begin
    return q'{
      select pd."HAS_USER_TAB",pd."DB_VERSION",pd."PARSE_SCHEMA",pd."PLAN_HASH_FULL",pd."PLAN_HASH",pd."PLAN_HASH_2",pd."PEEKED_BINDS",pd."XPLAN_STATS",pd."QB_REGISTRY",pd."OUTLINE_DATA",pd."HINT_USAGE"
      from xmltable(
         '/report/sql_monitor_report/plan/operation[@id="1"]/other_xml'
         passing xmldata
         columns
            has_user_tab      varchar2(200) path './info[@type="has_user_tab"   ]'
           ,db_version        varchar2(200) path './info[@type="db_version"     ]'
           ,parse_schema      varchar2(200) path './info[@type="parse_schema"   ]'
           ,plan_hash_full    int           path './info[@type="plan_hash_full" ]'
           ,plan_hash         int           path './info[@type="plan_hash"      ]'
           ,plan_hash_2       int           path './info[@type="plan_hash_2"    ]'
           ,peeked_binds      xmltype       path './peeked_binds'
           ,xplan_stats       xmltype       path './stats       '
           ,qb_registry       xmltype       path './qb_registry '
           ,outline_data      xmltype       path './outline_data'
           ,hint_usage        xmltype       path './hint_usage  '
      ) pd
    }';
  end;

  function rtsm_xml_macro_plan_ops(xmldata xmltype) return varchar2 SQL_MACRO
  is
  begin
    return q'{
      select po.*
      from xmltable(
         '/report/sql_monitor_report/plan/operation'
         passing xmldata
         columns
           --op             xmltype       path '.',
           id             int           path '@id'
          ,name           varchar2(100) path '@name'
          ,options        varchar2(100) path '@options'
          ,depth          int           path '@depth'
          ,pos            int           path '@pos'
          ,object         varchar2(128) path './object'
          ,object_alias   varchar2(200) path './object_alias'
          ,qblock         varchar2(200) path './qblock'
          ,card           int           path './card    '
          ,bytes          int           path './bytes   '
          ,cost           int           path './cost    '
          ,io_cost        int           path './io_cost '
          ,cpu_cost       int           path './cpu_cost'
          ,time           varchar2(100) path './time'
          ,access_pred    varchar2(4000) path './predicates[@type="access"]'
          ,filter_pred    varchar2(4000) path './predicates[@type="filter"]'
          ) po
    }';
  end;
  
  function rtsm_xml_macro_plan_monitor(xmldata xmltype) return varchar2 SQL_MACRO
  is
  begin
    return q'{
      select 
         id, parent_id, name, options, depth, position, skp, object_type, object_owner, object_name
        ,round(100*ratio_to_report(nvl(wait_samples_total,0)) over(),3) as TIME_SPENT_PERCENTAGE
        , optim_cardinality, optim_bytes, optim_cost, optim_cpu_cost, optim_io_cost, optim_time, first_active, last_active
        , duration, from_most_recent, from_sql_exec_start, starts, max_starts, dop, cardinality, max_card, read_reqs, max_read_reqs, read_bytes, max_read_bytes, first_row
        , memory, max_memory, min_max_mem, temp, max_temp, max_max_temp, write_reqs, max_write_reqs, write_bytes, max_write_bytes, spill_count, io_inter_bytes, max_io_inter_bytes
        , cell_offload_efficiency
        , time_left, percent_complete
        , nvl(wait_samples_total,0) as wait_samples_total
        , wait_samples_user_io, wait_samples_scheduler, wait_samples_other, wait_samples_network, wait_samples_cpu, wait_samples_concurrency, wait_samples_configuration, wait_samples_cluster, wait_samples_application
      from xmltable(
         '/report/sql_monitor_report/plan_monitor/operation'
         passing xmldata
         columns
           --op             xmltype       path '.',
           id             int           path '@id'
          ,parent_id      int           path '@parent_id'
          ,name           varchar2(100) path '@name'
          ,options        varchar2(100) path '@options'
          ,depth          int           path '@depth'
          ,position       int           path '@position'
          ,skp            int           path '@skp'
          ,object_type    varchar2(128) path './object/@type'
          ,object_owner   varchar2(128) path './object/owner'
          ,object_name    varchar2(128) path './object/name'
          --<optimizer>
          ,optim_cardinality    number        path './optimizer/cardinality'
          ,optim_bytes          number        path './optimizer/bytes      '
          ,optim_cost           number        path './optimizer/cost       '
          ,optim_cpu_cost       number        path './optimizer/cpu_cost   '
          ,optim_io_cost        number        path './optimizer/io_cost    '
          ,optim_time           number        path './optimizer/time       '
          --<stats>
          --,stats_pm       xmltype       path './stats[@type="plan_monitor"]'
          --,stats_npm      xmltype       path './stats[@type!="plan_monitor"]'

          ,first_active              varchar2(30)  path'./stats/stat[@name="first_active"]'
          ,last_active               varchar2(30)  path'./stats/stat[@name="last_active"]'
          ,duration                  number        path'./stats/stat[@name="duration"]'
          ,from_most_recent          number        path'./stats/stat[@name="from_most_recent"]'
          ,from_sql_exec_start       number        path'./stats/stat[@name="from_sql_exec_start"]'
          ,starts                    number        path'./stats/stat[@name="starts"]'
          ,max_starts                number        path'./stats/stat[@name="max_starts"]'
          ,dop                       number        path'./stats/stat[@name="dop"]'
          ,cardinality               number        path'./stats/stat[@name="cardinality"]'
          ,max_card                  number        path'./stats/stat[@name="max_card"]'
          ,read_reqs                 number        path'./stats/stat[@name="read_reqs"]'
          ,max_read_reqs             number        path'./stats/stat[@name="max_read_reqs"]'
          ,read_bytes                number        path'./stats/stat[@name="read_bytes"]'
          ,max_read_bytes            number        path'./stats/stat[@name="max_read_bytes"]'
          ,first_row                 varchar2(30)  path'./stats/stat[@name="first_row"]'
          ,memory                    number        path'./stats/stat[@name="memory"]'
          ,max_memory                number        path'./stats/stat[@name="max_memory"]'
          ,min_max_mem               number        path'./stats/stat[@name="min_max_mem"]'
          ,temp                      number        path'./stats/stat[@name="temp"]'
          ,max_temp                  number        path'./stats/stat[@name="max_temp"]'
          ,max_max_temp              number        path'./stats/stat[@name="max_max_temp"]'
          ,write_reqs                number        path'./stats/stat[@name="write_reqs"]'
          ,max_write_reqs            number        path'./stats/stat[@name="max_write_reqs"]'
          ,write_bytes               number        path'./stats/stat[@name="write_bytes"]'
          ,max_write_bytes           number        path'./stats/stat[@name="max_write_bytes"]'
          ,spill_count               number        path'./stats/stat[@name="spill_count"]'
          ,io_inter_bytes            number        path'./stats/stat[@name="io_inter_bytes"]'
          ,max_io_inter_bytes        number        path'./stats/stat[@name="max_io_inter_bytes"]'
          ,cell_offload_efficiency   number        path'./stats/stat[@name="cell_offload_efficiency"]'
          ,time_left                 number        path'./stats/stat[@name="time_left"]'
          ,percent_complete          number        path'./stats/stat[@name="percent_complete"]'
          --,activity_sampled           xmltype     path 'activity_sampled'
          ,wait_samples_total                number       path 'sum(./activity_sampled/activity)'
          ,wait_samples_User_IO              number       path 'sum(./activity_sampled/activity[@class="User I/O"     ])'
          ,wait_samples_Scheduler            number       path 'sum(./activity_sampled/activity[@class="Scheduler"    ])'
          ,wait_samples_Other                number       path 'sum(./activity_sampled/activity[@class="Other"        ])'
          ,wait_samples_Network              number       path 'sum(./activity_sampled/activity[@class="Network"      ])'
          ,wait_samples_Cpu                  number       path 'sum(./activity_sampled/activity[@class="Cpu"          ])'
          ,wait_samples_Concurrency          number       path 'sum(./activity_sampled/activity[@class="Concurrency"  ])'
          ,wait_samples_Configuration        number       path 'sum(./activity_sampled/activity[@class="Configuration"])'
          ,wait_samples_Cluster              number       path 'sum(./activity_sampled/activity[@class="Cluster"      ])'
          ,wait_samples_Application          number       path 'sum(./activity_sampled/activity[@class="Application"  ])'
       ) pm
    }';
  end;
  
end PKG_RTSM;
/
