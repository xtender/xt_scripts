col cur_n         for 999 noprint;

col sql_id        for a13;
col child_number  for 999;

col all_reasons   for a80;

col reason_n      for 999 heading N;
col reason        for a35;
col name          for a50;
col val           for a50;
break on sql_id on child_number on all_reasons on reason_n on reason# on reason skip 1;


with sql_shared as (
   select--+ NO_XML_QUERY_REWRITE materialize
      x1.cur_n
     ,x1.sql_id       
     ,x1.ADDRESS      
     ,x1.CHILD_ADDRESS
     ,x1.CHILD_NUMBER
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
   where x2.x_key not in ('ROW'
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
   --s.cur_n,
   s.sql_id       
--  ,s.ADDRESS      
--  ,s.CHILD_ADDRESS
  ,s.child_number
  ,r.reasons            as all_reasons
   ,x.child_node_n      as reason_n
   ,x.child_node_id     as reason#
   ,x.child_node_reason as reason
   ,x2.n2               as param#
   ,x2.name
   ,x2.val
from sql_shared s
    ,reasons r
    ,v$sql_shared_cursor s2
    ,xmltable( 
               '/XMLDATA/ChildNode'
               passing xmltype('<XMLDATA>'||reason||'</XMLDATA>')
               columns 
                   child_node_n      for ordinality
                  ,child_node_Child  number        path 'ChildNumber'
                  ,child_node_id     number        path './ID'
                  ,child_node_reason varchar2(400) path 'reason'
                  ,child_node        xmltype       path '.'
    )(+)  x
   ,xmltable(
               '/ChildNode/*[not(name(.)=("ChildNumber","reason", "ID"))]'
               passing child_node
               columns 
                   n2   for ordinality
                  ,name varchar2(100) path 'name()'
                  ,val  varchar2(400) path '.'

            )(+) x2

where 
      r.cur_n (+)     = s.cur_n
  and s2.sql_id       = '&1'
  and s2.sql_id       = s.sql_id
  and s2.child_number = s.child_number
order by sql_id,child_number,all_reasons,reason_n,reason#,reason,param#
/
col cur_n         clear;

col sql_id        clear;
col child_number  clear;

col all_reasons   clear;

col reason_n      clear;
col reason        clear;
col name          clear;
col val           clear;
clear break;
