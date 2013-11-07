---------------------------------------------------------------------------------------
-- Init:
@inc/input_vars_init;
set feedback off ver off timing off
prompt &_C_REVERSE *** Find SQL profile hints by mask "&1" &_C_RESET
---------------------------------------------------------------------------------------
def _hint_mask="&1"
-- extra params:
set termout off
col if_q            new_value _if_q
col if_nq           new_value _if_nq
select 
       case when upper('&1 &2 &3') like '%+Q%' then ''
         else '--'
       end if_q
      ,case when upper('&1 &2 &3') like '%+Q%' then '--'
         else ''
       end if_nq
from dual;
set termout on
---------------------------------------------------------------------------------------
-- formatting:
col name            format a30
col outline_hints   format a200
break on name skip 1

@switch "substr('&_O_RELEASE',1,2)" 

   @when "'11'" then
      select--+ NO_XML_QUERY_REWRITE
         &_if_nq    p.name  as name
         &_if_nq   ,decode(p.obj_type,1,'Profile',2,'Baseline',3,'Patch') type
         &_if_nq   ,x.n
         &_if_nq   ,x.hints as outline_hints 
         &_if_q    ',q''['||x.hints||']''' as outline_hints 
      from sys.sqlobj$ p
          ,sys.sqlobj$data sd
          ,xmltable('/outline_data/hint' 
                    passing xmltype(sd.comp_data)
                    columns 
                       n     for ordinality,
                       hints varchar2(200) path '.'
                   ) x
      where
           upper(x.hints) like upper('&_hint_mask')
       and p.signature = sd.signature 
       and p.category  = sd.category
       and p.obj_type  = sd.obj_type
      order by    p.name,x.n
   ;
   /* end when */

   @when "'10'" then
      select
         &_if_nq     p.name   as profile_name
         &_if_nq    ,h.attr#  as n
         &_if_nq    ,attr_val as outline_hints 
         &_if_q    ','''||replace(attr_val,'''','''''')||'''' as outline_hints 
      from 
           dba_sql_profiles p
          ,sys.sqlprof$attr h 
      where 
           upper(h.attr_val) like '&_hint_mask'
       and p.category  = h.category  
       and p.signature = h.signature
      order by    p.name,h.attr#
      ;
   /* end when */

/* end switch */

---------------------------------------------------------------------------------------
-- reset all
undef profile_name _if_nq _if_q
set feedback on
@inc/input_vars_undef;