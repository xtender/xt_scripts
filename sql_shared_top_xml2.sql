col sql_text                format a50;
col cur_n                   format 999;
col sql_id                  format a13;
col CHILD_NUMBER            format 999;

col reasons                 format a80 heading FEEDBACK     ;
col reason                  format a70 heading reason                 ;

break on sql_text

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
     ,xmltable('/ROWSET/ROW'
               passing xmltype(cursor(select c.* from v$sql_shared_cursor c where c.sql_id=tv.sql_id))
               columns 
                 CUR_N         for ordinality
                ,X_DATA        xmltype      path '.'
                ,SQL_ID        varchar2(14) path 'SQL_ID'
                ,ADDRESS       varchar2(16) path 'ADDRESS'
                ,CHILD_ADDRESS varchar2(16) path 'CHILD_ADDRESS'
                ,CHILD_NUMBER  number       path 'CHILD_NUMBER'
                ,REASON        varchar2(4000) path 'substring(/ROWSET/ROW/REASON,1,1000)'
      ) x1
     ,xmltable('//*'
               passing x1.x_data
               columns 
                 x_n   for ordinality
                ,x_key varchar2(30)   path 'name()'
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
col sql_text                clear
col cur_n                   clear
col sql_id                  clear
col CHILD_NUMBER            clear

col reasons                 clear
col reason                  clear
