col query_tab     format a40;
col object_type   format a20;
col object_owner  format a30;
col object_name   format a30;
col parent_tab    format a30;

with v as (
      select s.sql_id
            ,s.sql_text
            ,length(s.sql_text) l
            ,case 
               when length(s.sql_text)>=1000 
                  then to_char(regexp_replace(s.sql_fulltext ,'.*FROM "([^"]+)"."([^"]+)".*','\1.\2'))
               else    to_char(regexp_replace(s.sql_text     ,'.*FROM "([^"]+)"."([^"]+)".*','\1.\2'))
             end query_tab
            --,s.sql_fulltext
      --      ,p.CHILD_NUMBER
      --      ,p.ID
      --      ,p.OPERATION
      --      ,p.OPTIONS
            ,p.OBJECT#
            ,p.OBJECT_TYPE
            ,p.OBJECT_OWNER
            ,p.OBJECT_NAME
            ,case 
                when p.OBJECT_TYPE like 'INDEX%' 
                   then (select max(table_name) from dba_indexes i where i.owner=p.OBJECT_OWNER and i.index_name=p.OBJECT_NAME)
             end parent_tab
            ,case 
                when p.OBJECT_TYPE like 'INDEX%' 
                   then (select max(last_analyzed) from dba_ind_statistics i_st where i_st.owner=p.OBJECT_OWNER and i_st.index_name=p.OBJECT_NAME)
                when p.OBJECT_TYPE like 'TABLE%' 
                   then (select max(last_analyzed) from dba_tab_statistics t_st where t_st.owner=p.OBJECT_OWNER and t_st.TABLE_NAME=p.OBJECT_NAME)
                else to_date(null)
             end last_analyzed
      from v$sqlarea s
          ,v$sql_plan p
      where 
           s.sql_text like 'SELECT /* OPT_DYN_SAMP */ /*+%'
       and s.sql_id   = p.SQL_ID
       and p.object_owner is not null 
       and p.object_name  is not null
      order by s.sql_id,s.sql_text,p.CHILD_NUMBER,p.ID
)
select distinct
      query_tab
     ,object_type
     ,object_owner
     ,object_name
     ,object_type
     ,object#
     ,parent_tab
     ,last_analyzed
from v
order by query_tab,object_owner,object_name
/
col query_tab     clear;
col object_type   clear;
col object_owner  clear;
col object_name   clear;
col parent_tab    clear;
