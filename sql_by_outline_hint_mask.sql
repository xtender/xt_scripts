col hint   for a30;
col params for a80;
with 
 other_xml as (
    select
        sql_id, xmltype(other_xml) as other_xml
    from
        gv$sql_plan
    where
         plan_hash_value > 0
     and other_xml is not null
     and upper(other_xml) like upper('%&1%')
     and id=1
)
, hints as (
   select
      sql_id
     ,decode(instr(d.hint,'('),0,d.hint,substr(d.hint,1,instr(d.hint,'(')-1)) hint
     ,decode(instr(d.hint,'('),0,''    ,substr(d.hint,instr(d.hint,'('))) params
   from 
     other_xml o
    ,xmltable('/other_xml/outline_data/*'
         passing o.other_xml
         columns
            "HINT" varchar2(4000) PATH '/hint'
     ) d
   where upper(d.hint) like upper('%&1%')
)
select sql_id
      ,hint
      ,params
from hints
where rownum<=10
/
col hint   clear;
col params clear;
