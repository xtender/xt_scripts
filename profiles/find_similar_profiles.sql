with 
 sqlarea as (
     select/*+ materialize */ 
         sql_id
        ,sql_text
     from v$sqlarea aa
     where aa.sql_profile is null
 )
,profiles as (
     select/*+ materialize */ 
         name
        ,cast(substr(sql_text,1,2000) as varchar2(2000 )) as sql_text
        ,created
        ,last_modified
        ,description 
     from dba_sql_profiles pp
 )
,t as (
     select 
         a.sql_id
        ,p.sql_text prof_text
        ,p.name
        ,p.description
        ,length(
             regexp_substr( 
                utl_raw.bit_xor(
                    utl_raw.cast_to_raw(substr(a.sql_text,1,2000))
                   ,utl_raw.cast_to_raw(substr(p.sql_text,1,2000))
                )
               ,'(00)+')
             )
             /2 
             as common_length
        ,length(a.sql_text) query_len
        ,length(p.sql_text) prof_len
        ,least(
             length(a.sql_text)
            ,length(p.sql_text)
            ) as min_length
      from sqlarea a
          ,profiles p
      where substr(a.sql_text,1,100)=substr(p.sql_text,1,100)
 ) 
,t1 as (
      select t.*
            ,row_number()over(partition by t.sql_id order by common_length desc) rn
      from t
      where common_length>0
)
select t1.*
      ,aa.sql_fulltext
      ,length(aa.sql_fulltext) full_length
from t1,v$sqlarea aa
where rn=1
  and aa.sql_id=t1.sql_id
  and common_length/min_length >0.5
/
