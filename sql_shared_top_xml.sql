col CHILD_NUMBER            format 99999;
col sql_type_mismatch       format a8 heading sql_type_mismatch      ;
col OPTIMIZER_MISMATCH      format a9 heading OPTIMIZER_MISMATCH     ;
col OUTLINE_MISMATCH        format a7 heading OUTLINE_MISMATCH       ;
col STATS_ROW_MISMATCH      format a9 heading STATS_ROW_MISMATCH     ;
col LITERAL_MISMATCH        format a7 heading LITERAL_MISMATCH       ;
col BIND_MISMATCH           format a4 heading BIND_MISMATCH          ;
col REMOTE_TRANS_MISMATCH   format a6 heading REMOTE_TRANS_MISMATCH  ;
col USER_BIND_PEEK_MISMATCH format a9 heading USER_BIND_PEEK_MISMATCH;
col OPTIMIZER_MODE_MISMATCH format a9 heading OPTIMIZER_MODE_MISMATCH;
col USE_FEEDBACK_STATS      format a8 heading FEEDBACK     ;
col reason                  format a70 heading reason                 ;

with t1 as (
   select a.sql_text
         ,a.sql_id
   from v$sqlarea a 
   where executions>0 
   order by a.VERSION_COUNT desc
)--------------
,top_versions as (
   select * 
   from t1
   where rownum<=&cnt
)--------------
,sql_data as (
   select 
      tv.sql_text
     ,cur_n
     ,x1.sql_id       
     ,ADDRESS      
     ,CHILD_ADDRESS
     ,CHILD_NUMBER
     ,REASON
     ,x2.x_n       
     ,x2.x_key
     ,x2.x_val
   from 
      top_versions tv
     ,xmltable('for $r in ora:view("PUBLIC","V$SQL_SHARED_CURSOR")
                    where $r/ROW/SQL_ID=$SQL_ID
                       return $r
                       '
               passing tv.sql_id as "SQL_ID"
               columns 
                 CUR_N         for ordinality
                ,X_DATA        xmltype      path '.'
                ,SQL_ID        varchar2(14) path 'SQL_ID'
                ,ADDRESS       varchar2(16) path 'ADDRESS'
                ,CHILD_ADDRESS varchar2(16) path 'CHILD_ADDRESS'
                ,CHILD_NUMBER  number       path 'CHILD_NUMBER'
                ,REASON        varchar2(4000) path '"a"'--substring(./ROW/REASON/text(),1,1000)'
      ) x1
     ,xmltable('/ROW/*'
               passing x1.x_data
               columns 
                 x_n   for ordinality
                ,x_key varchar2(500)   path 'name()'
                ,x_val varchar2(1000) path '.'
              )(+) x2
)
,t_filter as (
   select
         sql_text 
        ,cur_n
        ,sql_id       
        ,ADDRESS      
        ,CHILD_ADDRESS
        ,CHILD_NUMBER
        ,REASON
        ,count(decode(x_val,'Y',1)) over(partition by sql_id,x_key) if_yes
        ,x_n
        ,x_key
        ,x_val
   from sql_data t
   where t.x_key not in ( 'ROW'
                         ,'SQL_ID'
                         ,'ADDRESS'
                         ,'CHILD_ADDRESS'
                         ,'CHILD_NUMBER'
                         ,'REASON')
)
select 
   sql_text
  ,cur_n
  ,sql_id       
--  ,ADDRESS      
--  ,CHILD_ADDRESS
  ,CHILD_NUMBER
  ,listagg(X_KEY||'='||x_val,', ') within group(order by x_key) reasons
  ,REASON
from t_filter 
where    if_yes > 0
group by sql_text
        ,cur_n
        ,sql_id       
        ,ADDRESS      
        ,CHILD_ADDRESS
        ,CHILD_NUMBER
        ,REASON
/
col CHILD_NUMBER            clear
col sql_type_mismatch       clear
col OPTIMIZER_MISMATCH      clear
col OUTLINE_MISMATCH        clear
col STATS_ROW_MISMATCH      clear
col LITERAL_MISMATCH        clear
col BIND_MISMATCH           clear
col REMOTE_TRANS_MISMATCH   clear
col USER_BIND_PEEK_MISMATCH clear
col OPTIMIZER_MODE_MISMATCH clear
col USE_FEEDBACK_STATS      clear
col reason                  clear
