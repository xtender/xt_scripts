def _mask='([, ]*\:"SYS_B_\d+")+';
def _JARO_WINKLER_DISTANCE=70;
accept _sql_id      prompt "Enter sql_id: " default 'n';
accept _with_select      prompt "Consider select-list? [Y/N, default=N]: " default 'n';
       
col prf_name             format a20;
col prf_description      format a20 word;
col sql_signature        format a20;
col prf_signature        format a20;
col sql_text_normalized  format a80 word;
col prf_text_normalized  format a80 word;
col sql_fulltext         format a80 word;
col prf_sql_text         format a80 word;

col elaexe               format 9999.9990;





with
 sqlarea_norm as (
     select
         sql_id
        ,sql_profile
        --,sql_fulltext as sql_text
        ,force_matching_signature as sql_signature
        ,case 
             when sql_fulltext like '%:"SYS_B_%' 
                then cast(substrb(
                                regexp_replace(sql_fulltext,'&_mask',':"SYS_B_XXX"') 
                               ,1,4000) as varchar2(4000))
             else cast(substrb(sql_fulltext,1,4000) as varchar2(4000))
         end
            as sql_text_normalized
     from 
         (
          select sql_id, sql_profile, force_matching_signature, cast(substrb(sql_fulltext,1,4000)as varchar2(4000)) sql_fulltext from v$sqlarea aa where aa.sql_id = '&_sql_id' and rownum=1
          union
          select sql_id, null       ,null                      , cast(substrb(sql_text,1,4000)as varchar2(4000)) from dba_hist_sqltext st where st.sql_id = '&_sql_id' and st.dbid = (select dbid from v$database) and rownum=1
         )
)
,profiles_norm as (
     select 
         name             as prf_name
        ,sql_text         as prf_sql_text
        ,signature        as prf_signature
        ,cast(substrb(regexp_replace(sql_text,'&_mask',':"SYS_B_XXX"'),1,4000) as varchar2(4000)) as prf_text_normalized
        ,created          as prf_created
        ,last_modified    as prf_last_modified
        ,description      as prf_description
     from dba_sql_profiles pp
)
,sqlarea as (
     select/*+ materialize */ 
         sql_id
        ,sql_signature
        ,case when upper('&_with_select')='Y' then sql_text_normalized
              else regexp_replace(sql_text_normalized,'^select.*? from ','select ... from ',1,1,'i')
         end sql_text_normalized
     from sqlarea_norm aa
     where aa.sql_profile is null
 )
,profiles as (
     select/*+ materialize */ 
         prf_name
        ,prf_signature
        ,case when upper('&_with_select')='Y' then prf_text_normalized
              else regexp_replace(prf_text_normalized,'^select.*? from ','select ... from 
                 ',1,1,'i')
         end prf_text_normalized
        ,prf_created
        ,prf_last_modified
        ,prf_description
     from profiles_norm pp
 )
,t as (
     select/*+ no_merge */
         a.sql_id
        ,prf_name
        ,prf_description
        /*
        ,length(
             regexp_substr( 
                utl_raw.bit_xor(
                    utl_raw.cast_to_raw(substr(a.sql_text_normalized,1,2000))
                   ,utl_raw.cast_to_raw(substr(p.prf_text_normalized,1,2000))
                )
               ,'(00)+')
             )
             /2 
             as common_length*/
        ,utl_match.EDIT_DISTANCE(sql_text_normalized,prf_text_normalized) as levenstein
        ,utl_match.jaro_winkler_similarity(sql_text_normalized,prf_text_normalized)  as jaro_winkler
        ,to_char(sql_signature,'tm9')                                     as sql_signature
        ,to_char(prf_signature,'tm9')                                     as prf_signature
        ,length(a.sql_text_normalized)                                    as sql_len
        ,length(p.prf_text_normalized)                                    as prf_len
        ,sql_text_normalized
        ,prf_text_normalized
      from sqlarea a
          ,profiles p
      where substr(a.sql_text_normalized,1,100)=substr(p.prf_text_normalized,1,100)
 ) 
,t1 as (
      select t.*
            ,row_number()over(order by jaro_winkler desc) rn
      from t
      where jaro_winkler>&_JARO_WINKLER_DISTANCE
)
select--+ leading(t1)
       t1.sql_id
      ,t1.prf_name
      ,decode(executions,0,0,aa.ELAPSED_TIME/1e6/aa.executions) elaexe
      ,t1.prf_description
--      ,t1.common_length
      ,levenstein
      ,jaro_winkler
      ,sql_signature
      ,prf_signature
      ,t1.sql_len
      ,t1.prf_len
      ,length(aa.sql_fulltext) full_length
      ,t1.prf_text_normalized
      ,t1.sql_text_normalized
--      ,aa.sql_fulltext
--      ,(select p.sql_text from dba_sql_profiles p where p.name=prf_name) prf_sql_text
from t1,v$sqlarea aa
where aa.sql_id=t1.sql_id
  and rn<=15
/
col prf_name            clear;
col prf_description     clear;

col sql_signature       clear;
col prf_signature       clear;

col sql_text_normalized clear;
col prf_text_normalized clear;
col sql_fulltext        clear;
col prf_sql_text        clear;
