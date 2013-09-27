----------------------------------------------------------------------------------------
--
-- File name:   sql_profile_hints.sql
--
-- Purpose:     Show hints associated with a SQL Profile.
--              Based on Kerry Osborne's profile_hints
--
-- Usage:       To show all profiles with hints:    @profiles/sql_profile_hints
--              To show hints of specific profile:  @profiles/sql_profile_hints PROFILE_NAME
--
--              To show enquoted hints only:        @profiles/sql_profile_hints +quote
--                                      or          @profiles/sql_profile_hints +q
--                                      or          @profiles/sql_profile_hints PROFILE_NAME +q
--                                      or          @profiles/sql_profile_hints PROFILE_NAME +quote
--
--              profile_name - the name of the SQL profile
--
-- Description: This script pulls the hints associated with a SQL Profile.
--
-- Mods:        Modified to check for 10g or 11g as the hint structure changed.
--              Modified to join on category as well as signature.
--              Modified to one query only with extra params. //S.Malakshinov http://orasql.org
--              
--              See http://kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
-- Init:
@inc/input_vars_init;
set feedback off ver off timing off
prompt Show SQL profile hints:
---------------------------------------------------------------------------------------
-- extra params:
set termout off
col if_q            new_value _if_q
col if_nq           new_value _if_nq
col _profile_name   new_value _profile_name
select 
       case when upper('&1 &2 &3') like '%+Q%' then ''
         else '--'
       end if_q
      ,case when upper('&1 &2 &3') like '%+Q%' then '--'
         else ''
       end if_nq
      ,case when substr('&1',1,1)!='+' then upper('%&1%')
            else '%'
       end "_profile_name"
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
         &_if_q    ',q''['||x.hints||']' as outline_hints 
      from sys.sqlobj$ p
          ,sys.sqlobj$data sd
          ,xmltable('/outline_data/hint' 
                    passing xmltype(sd.comp_data)
                    columns 
                       n     for ordinality,
                       hints varchar2(200) path '.'
                   ) x
      where
           upper(p.name) like upper('&_profile_name')
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
           upper(p.name) like '&_profile_name'
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