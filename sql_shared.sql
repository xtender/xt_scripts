col cur_n         for 999 heading N;
col sql_id        for a13;
col ADDRESS       for a16;
col CHILD_ADDRESS for a16;
col CHILD_NUMBER  for 999;
col reasons       for a80;
col REASON        for a50;

with sql_shared as (
   select--+ NO_XML_QUERY_REWRITE materialize
      x1.cur_n
     ,x1.sql_id       
     ,x1.ADDRESS      
     ,x1.CHILD_ADDRESS
     ,x1.CHILD_NUMBER
     ,x1.REASON
     ,x1.X_DATA
   from 
      table(xmlsequence(xmltype(cursor(select c.* from v$sql_shared_cursor c where c.sql_id='&1')))) sq
     ,xmltable('/ROWSET/ROW'
               passing sq.column_value
               columns 
                 CUR_N         for ordinality
                ,X_DATA        xmltype      path '.'
                ,SQL_ID        varchar2(14) path 'SQL_ID'
                ,ADDRESS       varchar2(16) path 'ADDRESS'
                ,CHILD_ADDRESS varchar2(16) path 'CHILD_ADDRESS'
                ,CHILD_NUMBER  number       path 'CHILD_NUMBER'
                ,REASON        xmltype      path 'REASON'
      ) x1
)
,params as (
   select 
         t.cur_n
        ,count(decode(x_val,'Y',1)) over(partition by x_key) if_yes
        ,x2.x_n       
        ,x2.x_key
        ,x2.x_val
   from sql_shared t
       ,xmltable('//*[empty(fn:index-of(( "ROW","SQL_ID","ADDRESS","CHILD_ADDRESS","CHILD_NUMBER","REASON"),name()))]'
         passing t.x_data
         columns 
           x_n   for ordinality
          ,x_key varchar2(30)   path 'name()'
          ,x_val varchar2(1000) path '.'
        ) x2
   where x2.x_key not in ( 'ROW'
                         ,'SQL_ID'
                         ,'ADDRESS'
                         ,'CHILD_ADDRESS'
                         ,'CHILD_NUMBER'
                         ,'REASON')
),reasons as(
   select
        p.cur_n
       ,listagg(X_KEY||'='||x_val,', ') within group(order by x_key) reasons
   from params p
   where p.if_yes > 0
   group by p.cur_n
)
select 
   s.cur_n
  ,s.sql_id       
  ,s.ADDRESS      
  ,s.CHILD_ADDRESS
  ,s.CHILD_NUMBER
  ,r.reasons
  ,s.REASON
from sql_shared s
    ,reasons r
where 
      r.cur_n (+) = s.cur_n
/
