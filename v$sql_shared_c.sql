col cur_n 		for 99
col sql_id 		for a13
col ADDRESS 	for a16
col CHILD_ADDRESS for a16
col CHILD_NUMBER for 99
col reasons		for a70
col REASON		for a70


with sql_data as (
   select 
      cur_n
     ,sql_id       
     ,ADDRESS      
     ,CHILD_ADDRESS
     ,CHILD_NUMBER
     ,REASON
     ,x2.x_n       
     ,x2.x_key
     ,x2.x_val
   from 
      xmltable('/ROWSET/ROW'
               passing xmltype(cursor(select c.* from v$sql_shared_cursor c where c.sql_id='&sql_id'))
               columns 
                 CUR_N         for ordinality
                ,X_DATA        xmltype      path '.'
                ,SQL_ID        varchar2(14) path 'SQL_ID'
                ,ADDRESS       varchar2(16) path 'ADDRESS'
                ,CHILD_ADDRESS varchar2(16) path 'CHILD_ADDRESS'
                ,CHILD_NUMBER  number       path 'CHILD_NUMBER'
                ,REASON        varchar2(4000) path 'substring(REASON,1,2000)'
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
         cur_n
        ,sql_id       
        ,ADDRESS      
        ,CHILD_ADDRESS
        ,CHILD_NUMBER
        ,REASON
        ,count(decode(x_val,'Y',1)) over(partition by x_key) if_yes
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
   cur_n
  ,sql_id       
  ,ADDRESS      
  ,CHILD_ADDRESS
  ,CHILD_NUMBER
  ,listagg(X_KEY||'='||x_val,', ') within group(order by x_key) reasons
  ,REASON
from t_filter 
where    if_yes > 0
group by cur_n
        ,sql_id       
        ,ADDRESS      
        ,CHILD_ADDRESS
        ,CHILD_NUMBER
        ,REASON
/
col cur_n 			clear
col ADDRESS 		clear
col CHILD_ADDRESS 	clear
col CHILD_NUMBER 	clear
col reasons			clear
col REASON			clear
