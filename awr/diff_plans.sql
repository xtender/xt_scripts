@inc/input_vars_init;
define A_SQLID=&1
define A_DBID='&2'

set termout off

col S_PRINT_SNAPS new_value S_PRINT_SNAPS noprint;
col B_PRINT_SNAPS new_value B_PRINT_SNAPS noprint;

select 
  case when lower('&2 &3') like '%+snaps%' then 'collect(st.snap_id)' else 'null'  end as S_PRINT_SNAPS
 ,case when lower('&2 &3') like '%+snaps%' then 'true'                else 'false' end as B_PRINT_SNAPS
from dual;

var c_out clob;

declare
   p_sqlid varchar2(15):='&A_SQLID';
   p_dbid  number:='&A_DBID';
   
   type clob_table is table of clob;
   a_info  clob_table:=clob_table();
   a_plan  clob_table:=clob_table();
   
   n       int:=0;
   v_out   clob;
   l_infoline clob;    
   l_planline clob;
   
   /** cursor c_plans */
   cursor c_plans(p_sqlid varchar2, p_dbid number, p_since timestamp default null) 
      is 
          select 
             sql_id
            ,st.parsing_schema_name                                        parsing_schema
            ,plan_hash_value                                               plan_hv
            ,sum(st.elapsed_time_delta)                                    ela
            ,sum(st.executions_delta)                                      execs
            ,sum(st.elapsed_time_delta)/nullif(sum(st.executions_delta),0) ela_per_exec
            ,min(begin_interval_time)                                      first_begin
            ,max(end_interval_time)                                        last_end
            ,min(st.snap_id)                                               first_snap
            ,max(st.snap_id)                                               last_snap
            ,count(distinct st.snap_id)                                    snaps_count
            ,cast(
                   &s_print_snaps
                   as sys.odcinumberlist
                 )                                                         snaps_list
          from 
             dba_hist_sqlstat st
            ,dba_hist_snapshot sn
          where 
                 st.snap_id = sn.snap_id
             and st.dbid    = p_dbid
             and sn.dbid    = p_dbid
             and st.sql_id  = p_sqlid
             and (p_since is null or sn.end_interval_time>=p_since)
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
    function format_info(p_info c_plans%rowtype)
       return clob 
    is v_snaps clob;
    begin
       if &b_print_snaps then 
          for i in 1..p_info.snaps_list.count loop
             v_snaps:=v_snaps||p_info.snaps_list(i)||',';
             if mod(i,10)=0 then 
                v_snaps:=v_snaps||chr(10);
             end if;
          end loop;
          v_snaps:=rtrim(v_snaps,',');
       else
          v_snaps:='disabled';
       end if;
       return     to_clob('')
                 ||'parsing_schema   : '||          p_info.parsing_schema
        ||chr(10)||'plan_hash_value  : '|| to_char( p_info.plan_hv          ,'FMTM9')
        ||chr(10)||'elapsed per exec : '|| to_char( p_info.ela_per_exec/1e6 ,'FM999G990d099999'     ,q'[nls_numeric_characters='.`']')
        ||chr(10)||'sum(elapsed),secs: '|| to_char( p_info.ela/1e6          ,'FM999G999G999G990'    ,q'[nls_numeric_characters='.`']')
        ||chr(10)||'executions       : '|| to_char( p_info.execs            ,'FM999G999G999G990'    ,q'[nls_numeric_characters='.`']')
        ||chr(10)||'first_begin      : '|| to_char( p_info.first_begin      ,'yyyy-mm-dd hh24:mi:ss')                           
        ||chr(10)||'last_end         : '|| to_char( p_info.last_end         ,'yyyy-mm-dd hh24:mi:ss')                           
        ||chr(10)||'first_snap       : '|| to_char( p_info.first_snap       ,'FM999G999G999G990'    ,q'[nls_numeric_characters='.`']')
        ||chr(10)||'last_snap        : '|| to_char( p_info.last_snap        ,'FM999G999G999G990'    ,q'[nls_numeric_characters='.`']')
        ||chr(10)||'snaps_count      : '|| to_char( p_info.snaps_count      ,'FM999G999G999G990'    ,q'[nls_numeric_characters='.`']')
        ||chr(10)||'snaps            : '|| v_snaps;
    end format_info;
    /** function get_plan */
    function get_plan( p_sqlid   in varchar2
                     , p_table   in varchar2 default 'v$sql_plan'
                     , p_plan_hv in number   default null
                     , p_format  in varchar2 default 'ADVANCED'
                     , p_type    in varchar2 default 'HTML'
                     , p_dbid    in number   default null
                     )
    return clob
    is
       l_filter varchar2(4000);
    begin
       l_filter:='sql_id='''||p_sqlid||''''
               ||case when p_plan_hv is not null then ' and plan_hash_value='||p_plan_hv end
               ||case when p_dbid    is not null then ' and dbid='||p_dbid end;
       
       return dbms_xplan.display_plan(
                  table_name   => p_table
                 ,format       => p_format
                 ,filter_preds => l_filter
                 ,type         => p_type
                );
    end get_plan;
    /** function td */
    function td(p_clob in clob) return clob is
       c_pre  constant varchar2(4000) :=q'[<td valign='top'><pre>]';
       c_post constant varchar2(4000) :='</pre></td>'||chr(10);
    begin
       return c_pre || p_clob ||c_post;
    end td;
    
begin
   if p_dbid is null then 
      select db.dbid into p_dbid from v$database db;
   end if;
   
   l_infoline:='<tr>';
   l_planline:='<tr>';
   for r in c_plans(p_sqlid, p_dbid)
   loop
      n:=n+1;
      a_info.extend;
      a_plan.extend;
      a_info(n):=format_info(r);
      a_plan(n):=get_plan( p_sqlid   => p_sqlid
                         , p_table   => 'DBA_HIST_SQL_PLAN'
                         , p_plan_hv => r.plan_hv
                         , p_dbid    => p_dbid
                         , p_type    => 'TEXT'
                         );
      l_infoline:=l_infoline||td(a_info(n));
      l_planline:=l_planline||td(a_plan(n));
   end loop;
   l_infoline:=l_infoline||'</tr>';
   l_planline:=l_planline||'</tr>';
   
   v_out:='<HTML><BODY><TABLE border=1>';
   v_out:=v_out||l_infoline;
   v_out:=v_out||l_planline;
   v_out:=v_out||'</table></body></html>';
   :c_out:=v_out;
end;
/
set termout off timing off ver off feed off head off lines 10000000 pagesize 0
spool &_TEMPDIR\plans_&A_SQLID..html
print c_out
spool off
host &_START &_TEMPDIR\plans_&A_SQLID..html
undef A_SQLID
@inc/input_vars_undef;
