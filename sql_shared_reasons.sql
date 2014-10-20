col reason_n      for 999 heading N;
col sql_id        for a13;
col child_number  for 999;
col reason        for a35;
col name          for a50;
col val           for a50;
break on sql_id on child_number on reason_n on reason# on reason skip 1;
select 
    s.sql_id            as sql_id
   ,child_number        as child_number
   ,x.child_node_n      as reason_n
   ,x.child_node_id     as reason#
   ,x.child_node_reason as reason
   ,x2.n2               as param#
   ,x2.name
   ,x2.val
from v$sql_shared_cursor s
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
where s.sql_id='&1'
order by sql_id,child_number,reason_n,reason#,reason,param#
/
col reason_n      clear;
col sql_id        clear;
col child_number  clear;
col reason        clear;
clear break;
