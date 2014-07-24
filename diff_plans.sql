prompt &_C_REVERSE *** Diff plans by sql_id. &_C_RESET
prompt Usage: @plans/diff_plans2 sqlid [+awr] [-v$sql]

@inc/input_vars_init;
define A_SQLID=&1

var c_out clob;

col p_awr   new_value p_awr;
col p_vsql  new_value p_vsql;
select 
   case when '&2 &3 &4 &5'     like '%+awr%'   then 'true'  else 'false' end p_awr
  ,case when '&2 &3 &4 &5' not like '%-v$sql%' then 'true'  else 'false' end p_vsql
from dual;

declare   
   type clob_table is table of clob;
   
   c_name_padding   constant int:=20;
   c_number_format  constant varchar2(24) := 'FM999G999G999G990D999999';
   c_integer_format constant varchar2(24) := 'FM999999999990';
   c_float_format   constant varchar2(24) := 'FM999G999G999G990D999990';
   c_numeric_chars  constant varchar2(30) :=q'[nls_numeric_characters='. ']';
   /** local functions: */
   function join_numlist( 
      numlist       in sys.odcinumberlist
     ,delim         in varchar2 default ','
     ,split_n       in int      default null
     ,split_delim   in varchar2 default null
   )
   return clob
   is
      res clob;
   begin
       for i in 1..numlist.count loop
          res:=res||numlist(i)||delim;
          if mod( i, split_n ) = 0 then 
             res:=res||split_delim;
          end if;
       end loop;
       return rtrim(split_delim,delim);
   end join_numlist;

   /**************/
   function td(p_clob in clob) return clob is
      c_pre  constant varchar2(4000) :=q'[<td valign='top'><pre>]';
      c_post constant varchar2(4000) :='</pre></td>'||chr(10);
   begin
      return c_pre || p_clob ||c_post;
   end td;
   /**************/
   function current_dbid return number
   is 
      dbid number;
   begin
     select db.dbid into dbid from v$database db;
     return dbid;
   end current_dbid;
   /**************/
   procedure add_to_clob  ( res in out clob, p_name in varchar2, p_value in VARCHAR2) 
   is
   begin
      res:=res||rpad(p_name,c_name_padding)||': '||p_value||chr(10);
   end add_to_clob;
   
   procedure add_to_clob  ( res in out clob, p_name in varchar2, p_value in NUMBER
                           ,p_format in varchar2 default c_number_format)
   is
   begin
      res:=res||rpad(p_name,c_name_padding)||': '||to_char(p_value,p_format,c_numeric_chars)||chr(10);
   end add_to_clob;
   
   procedure add_to_clob_f( res in out clob, p_name in varchar2, p_value in FLOAT
                           ,p_format in varchar2 default c_float_format)
   is
   begin
      res:=res||rpad(p_name,c_name_padding)||': '||to_char(p_value,p_format,c_numeric_chars)||chr(10);
   end add_to_clob_f;
   
   procedure add_to_clob_d( res in out clob, p_name in varchar2, p_value in INTEGER
                           ,p_format in varchar2 default c_integer_format)
   is
   begin
      res:=res||rpad(p_name,c_name_padding)||': '||to_char(p_value,p_format,c_numeric_chars)||chr(10);
   end add_to_clob_d;
   /**     end local functions */
   /****************************/
   
   /** function get_plan */
   function get_plan( p_sqlid   in varchar2
                    , p_table   in varchar2 default 'v$sql_plan'
                    , p_plan_hv in number   default null
                    , p_format  in varchar2 default 'ADVANCED +outline'
                    , p_type    in varchar2 default 'HTML'
                    , p_dbid    in number   default null
                    , p_extra_filter in varchar2 default null
                    )
   return clob
   is
      l_filter varchar2(4000);
   begin
      l_filter:='sql_id='''||p_sqlid||''''
              ||case when p_plan_hv is not null then ' and plan_hash_value='||p_plan_hv end
              ||case when p_dbid    is not null then ' and dbid           ='||p_dbid end;

      if p_extra_filter is not null then 
         l_filter:=l_filter||' and '||p_extra_filter;
      end if;

      return dbms_xplan.display_plan(
                 table_name   => p_table
                ,format       => nvl(p_format,'ADVANCED +outline')
                ,filter_preds => l_filter
                ,type         => p_type
               );
   end get_plan;

   /**********************************/
   /**          AWR plans            */
   procedure get_plans_awr(
      p_sqlid       in varchar2
     ,p_dbid        in number    default current_dbid
     ,p_since       in timestamp default null
     ,p_print_snaps in boolean   default false
     ,io_info       in out clob_table
     ,io_plan       in out clob_table
     ,p_format      in varchar2  default null
   )
   is
      /** cursor c_plans */
      cursor c_plans_awr(pc_sqlid varchar2, pc_dbid number, pc_since timestamp default null,pc_n_snaps int default 0)
         is 
             select 
                sql_id
               ,st.parsing_schema_name                                            parsing_schema
               ,plan_hash_value                                                   plan_hv
               ,sum(st.elapsed_time_delta)/1e6                                    ela
               ,sum(st.executions_delta  )                                        execs
               ,sum(st.elapsed_time_delta)/1e6/nullif(sum(st.executions_delta),0) ela_per_exec
               ,min(begin_interval_time  )                                        first_begin
               ,max(end_interval_time    )                                        last_end
               ,min(st.snap_id)                                                   first_snap
               ,max(st.snap_id)                                                   last_snap
               ,count(distinct st.snap_id)                                        snaps_count
               ,cast( collect(decode(pc_n_snaps,1,st.snap_id,null))
                      as sys.odcinumberlist
                    )                                                             snaps_list
             from 
                dba_hist_sqlstat st
               ,dba_hist_snapshot sn
             where 
                    st.snap_id = sn.snap_id
                and st.dbid    = pc_dbid
                and sn.dbid    = pc_dbid
                and st.sql_id  = pc_sqlid
                and (pc_since is null or sn.end_interval_time>=pc_since)
             group by 
                st.sql_id
               ,st.parsing_schema_name
               ,st.plan_hash_value
             order by 
                st.sql_id
               ,st.parsing_schema_name
               ,st.plan_hash_value;
       -- end cursor c_plans.
       ----------------------------
       /** function format_info */
       function format_info(p_info c_plans_awr%rowtype,b_print_snaps in boolean)
          return clob 
       is v_snaps clob;
          res clob;
       begin
          if b_print_snaps then 
             v_snaps := join_numlist( numlist => p_info.snaps_list, delim => ',', split_n => 10, split_delim=>chr(10) );
          else
             v_snaps := 'disabled';
          end if;
          add_to_clob  (res,'parsing_schema'    , p_info.parsing_schema );
          add_to_clob_d(res,'plan_hash_value'   , p_info.plan_hv        );
          
          return      'parsing_schema   : '||          p_info.parsing_schema
           ||chr(10)||'plan_hash_value  : '|| to_char( p_info.plan_hv     ,'FMTM9')
           ||chr(10)||'sum(elapsed),secs: '|| to_char( p_info.ela         ,'FM999G999G999G990'    ,q'[nls_numeric_characters='. ']')
           ||chr(10)||'executions       : '|| to_char( p_info.execs       ,'FM999G999G999G990'    ,q'[nls_numeric_characters='. ']')
           ||chr(10)||'exepsed per exec : '|| to_char( p_info.ela_per_exec,'FM999G990D999990'     ,q'[nls_numeric_characters='. ']')
           ||chr(10)||'first_begin      : '|| to_char( p_info.first_begin ,'yyyy-mm-dd hh24:mi:ss')
           ||chr(10)||'last_end         : '|| to_char( p_info.last_end    ,'yyyy-mm-dd hh24:mi:ss')
           ||chr(10)||'first_snap       : '|| to_char( p_info.first_snap  ,'FM999G999G999G990'    ,q'[nls_numeric_characters='. ']')
           ||chr(10)||'last_snap        : '|| to_char( p_info.last_snap   ,'FM999G999G999G990'    ,q'[nls_numeric_characters='. ']')
           ||chr(10)||'snaps_count      : '|| to_char( p_info.snaps_count ,'FM999G999G999G990'    ,q'[nls_numeric_characters='. ']')
           ||chr(10)||'snaps            : '|| v_snaps;
       end format_info;
   /* main block */
   begin
      for r in c_plans_awr(
                        p_sqlid
                       ,p_dbid
                       ,p_since
                       ,case when get_plans_awr.p_print_snaps then 1 else 0 end
                      )
      loop
         io_info.extend;
         io_plan.extend;
         io_info(io_info.count):=format_info(r, p_print_snaps);
         io_plan(io_plan.count):=get_plan( 
                                    p_sqlid   => r.sql_id
                                  , p_table   => 'DBA_HIST_SQL_PLAN'
                                  , p_plan_hv => r.plan_hv
                                  , p_dbid    => p_dbid
                                  , p_format  => p_format
                                  , p_type    => 'TEXT'
                                  );
      end loop;
   end get_plans_awr;

   procedure get_plans_v$sql(
      p_sqlid       in varchar2
     ,io_info       in out clob_table
     ,io_plan       in out clob_table
     ,p_format      in varchar2 default null
   )
   is
      /** cursor c_plans */
      cursor c_plans_v$sql(pc_sqlid varchar2 )
         is 
             select 
                st.sql_id
               ,st.parsing_schema_name                                            parsing_schema
               ,st.SQL_PROFILE                                                    sql_profile
               ,st.SQL_PATCH                                                      sql_patch
               ,st.SQL_PLAN_BASELINE                                              sql_plan_baseline
               ,st.plan_hash_value                                                plan_hv
               ,min(st.CHILD_NUMBER)                                              min_child_number
               ,sum(st.elapsed_time)     /1e6                                     ela
               ,sum(st.executions  )                                              execs
               ,sum(st.elapsed_time)     /1e6/nullif(sum(st.executions),0)        ela_per_exec
               ,sum(st.USER_IO_WAIT_TIME)/1e6/nullif(sum(st.executions),0)        ela_io
               ,sum(st.CPU_TIME         )/1e6/nullif(sum(st.executions),0)        ela_cpu
               ,min(st.FIRST_LOAD_TIME  )                                         first_load
               ,max(st.LAST_LOAD_TIME   )                                         last_load
               ,max(st.LAST_ACTIVE_TIME )                                         last_active
               ,sum(st.BUFFER_GETS      ) /nullif(sum(st.executions),0)           buffer_gets   
               ,sum(st.DISK_READS       ) /nullif(sum(st.executions),0)           disk_reads    
               ,sum(st.DIRECT_WRITES    ) /nullif(sum(st.executions),0)           direct_writes 
               ,sum(st.ROWS_PROCESSED   ) /nullif(sum(st.executions),0)           rows_processed
               ,st.IS_SHAREABLE                                                   is_shareable     
               ,st.IS_BIND_SENSITIVE                                              is_bind_sensitive
               ,st.IS_BIND_AWARE                                                  is_bind_aware
               ,st.PROGRAM_ID
               ,st.PROGRAM_LINE#
               ,count(st.CHILD_NUMBER)                                            children_count
               ,cast( collect(st.CHILD_NUMBER)
                      as sys.odcinumberlist
                    )                                                             children_list
             from 
                v$sql st
             where st.sql_id  = pc_sqlid
             group by 
                 st.sql_id
                ,st.parsing_schema_name
                ,st.PLAN_HASH_VALUE   
                ,st.SQL_PROFILE
                ,st.SQL_PATCH
                ,st.SQL_PLAN_BASELINE
                ,st.IS_SHAREABLE     
                ,st.IS_BIND_SENSITIVE
                ,st.IS_BIND_AWARE     
                ,st.PROGRAM_ID
                ,st.PROGRAM_LINE#
             order by 
                st.sql_id
               ,st.parsing_schema_name
               ,st.plan_hash_value
               ,st.PROGRAM_ID
               ,st.PROGRAM_LINE#;
       -- end cursor c_plans.
       ----------------------------
       /** function format_info */
       function format_info(p_info c_plans_v$sql%rowtype)
          return clob 
       is
          res clob;
       begin
           add_to_clob  (res,'parsing_schema'    , p_info.parsing_schema );
           add_to_clob_d(res,'plan_hash_value'   , p_info.plan_hv        );

           add_to_clob_d(res,'program_id'        , p_info.program_id     );
           add_to_clob_d(res,'program_id'        , p_info.program_line#  );
           add_to_clob_d(res,'child.count'       , p_info.children_count );
           add_to_clob  (res,'child.list'        , join_numlist( p_info.children_list ));
           
           add_to_clob  (res,'sql_profile'       , p_info.sql_profile       );
           add_to_clob  (res,'sql_patch'         , p_info.sql_patch         );
           add_to_clob  (res,'sql_baseline'      , p_info.sql_plan_baseline );
           
           add_to_clob  (res,'is_shareable'      , p_info.is_shareable      );
           add_to_clob  (res,'is_bind_sensitive' , p_info.is_bind_sensitive );
           add_to_clob  (res,'is_bind_aware'     , p_info.is_bind_aware     );
           
           add_to_clob_f(res,'elapsed_time'      , p_info.ela            );
           add_to_clob  (res,'executions'        , p_info.execs          );
           add_to_clob_f(res,'elapsed per exec'  , p_info.ela_per_exec   );
           add_to_clob_f(res,'io per exec'       , p_info.ela_io         );
           add_to_clob_f(res,'cpu per exec'      , p_info.ela_cpu        );
           add_to_clob  (res,'first load'        , p_info.first_load     );
           add_to_clob  (res,'last load'         , p_info.last_load      );
           add_to_clob  (res,'last active'       , to_char(p_info.last_active,'yyyy-mm-dd hh24:mi:ss'));
           
           add_to_clob_f(res,'buffer gets'       , p_info.buffer_gets    );
           add_to_clob_f(res,'disk reads'        , p_info.disk_reads     );
           add_to_clob_f(res,'direct writes'     , p_info.direct_writes  );
           add_to_clob_f(res,'rows_processed'    , p_info.rows_processed );

           return res;
       end format_info;
   begin
      for r in c_plans_v$sql(p_sqlid) loop
         io_info.extend;
         io_plan.extend;
         io_info(io_info.count):=format_info(r);
         io_plan(io_plan.count):=get_plan(
                                          p_sqlid   => r.sql_id
                                         ,p_table   => 'v$sql_plan_statistics_all'
                                         ,p_plan_hv => r.plan_hv
                                         ,p_format  => p_format
                                         ,p_type    => 'TEXT'
                                         ,p_extra_filter => 'child_number='||r.min_child_number
                                         );
      end loop;
   end get_plans_v$sql;
   
   /** function get_plans */
   function get_plans(p_sqlid in varchar2
                     ,p_format in varchar2 default null
                     ,p_awr   in varchar2 default 'true'
                     ,p_v$sql in varchar2 default 'true'
                     )
      return clob 
   is
      a_info     clob_table :=clob_table();
      a_plan     clob_table :=clob_table();
      l_infoline clob;
      l_planline clob;
      v_out      clob;
   begin
      if lower(p_awr)='true' then
         get_plans_awr(
            p_sqlid       => p_sqlid
           ,io_info       => a_info
           ,io_plan       => a_plan
           ,p_format      => p_format
         );
      end if;

      if lower(p_v$sql)='true' then
         get_plans_v$sql(
            p_sqlid       => p_sqlid
           ,io_info       => a_info
           ,io_plan       => a_plan
           ,p_format      => p_format
         );
      end if;
            
      l_infoline:='<tr>';
      l_planline:='<tr>';
      for i in 1..a_info.count
      loop
         l_infoline:=l_infoline||td(a_info(i));
         l_planline:=l_planline||td(a_plan(i));
      end loop;
      l_infoline:=l_infoline||'</tr>';
      l_planline:=l_planline||'</tr>';
      
      v_out:='<HTML><BODY><TABLE border=1>';
      v_out:=v_out||l_infoline;
      v_out:=v_out||l_planline;
      v_out:=v_out||'</TABLE></BODY></HTML>';
      return v_out;
   end;

begin
   :c_out:=get_plans('&A_SQLID', p_awr => '&p_awr',p_v$sql=>'&p_vsql');
end;
/

set termout off timing off ver off feed off head off lines 10000000 pagesize 0
spool &_TEMPDIR\plans_&A_SQLID..html
print c_out
spool off
host &_START &_TEMPDIR\plans_&A_SQLID..html
undef A_SQLID
@inc/input_vars_undef;
