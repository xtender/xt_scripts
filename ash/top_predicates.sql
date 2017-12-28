with 
 ash as (
   select 
      sql_id
     ,plan_hash_value
     ,table_name
     ,alias
     ,ACCESS_PREDICATES
     ,FILTER_PREDICATES
     ,count(*) cnt
   from (
      select 
         h.sql_id
        ,h.SQL_PLAN_HASH_VALUE plan_hash_value
        ,decode(p.OPERATION
                 ,'TABLE ACCESS',p.OBJECT_OWNER||'.'||p.OBJECT_NAME
                 ,(select i.TABLE_OWNER||'.'||i.TABLE_NAME from dba_indexes i where i.OWNER=p.OBJECT_OWNER and i.index_name=p.OBJECT_NAME)
               ) table_name
        ,OBJECT_ALIAS ALIAS
        ,p.ACCESS_PREDICATES
        ,p.FILTER_PREDICATES
      -- поля, которые могут быть полезны для анализа в других разрезах:
      --  ,h.sql_plan_operation
      --  ,h.sql_plan_options
      --  ,decode(h.session_state,'ON CPU','ON CPU',h.event) event
      --  ,h.current_obj#
      from v$active_session_history h
          ,v$sql_plan p
      where h.sql_opname='SELECT'
        and h.IN_SQL_EXECUTION='Y'
        and h.sql_plan_operation in ('INDEX','TABLE ACCESS')
        and p.SQL_ID = h.sql_id
        and p.CHILD_NUMBER = h.SQL_CHILD_NUMBER
        and p.ID = h.SQL_PLAN_LINE_ID
        -- если захотим за последние 3 часа:
        -- and h.sample_time >= systimestamp - interval '3' hour
   )
   -- если захотим анализируем предикаты только одной таблицы:
   -- where table_name='&OWNER.&TABNAME'
   group by 
      sql_id
     ,plan_hash_value
     ,table_name
     ,alias
     ,ACCESS_PREDICATES
     ,FILTER_PREDICATES
)
,agg_by_alias as (
   select
      table_name
     ,regexp_substr(ALIAS,'^[^@]+') ALIAS
     ,listagg(ACCESS_PREDICATES,' ') within group(order by ACCESS_PREDICATES) ACCESS_PREDICATES
     ,listagg(FILTER_PREDICATES,' ') within group(order by FILTER_PREDICATES) FILTER_PREDICATES
     ,sum(cnt) cnt
   from ash
   group by 
      sql_id
     ,plan_hash_value
     ,table_name
     ,alias
)
,agg as (
   select 
       table_name
      ,'ALIAS' alias
      ,replace(access_predicates,'"'||alias||'".','"ALIAS".') access_predicates
      ,replace(filter_predicates,'"'||alias||'".','"ALIAS".') filter_predicates
      ,sum(cnt) cnt
   from agg_by_alias 
   group by 
       table_name
      ,replace(access_predicates,'"'||alias||'".','"ALIAS".') 
      ,replace(filter_predicates,'"'||alias||'".','"ALIAS".') 
)
,cols as (
   select 
       table_name
      ,cols
      ,access_predicates
      ,filter_predicates
      ,sum(cnt)over(partition by table_name,cols) total_by_cols
      ,cnt
   from agg
       ,xmltable(
          'string-join(for $c in /ROWSET/ROW/COL order by $c return $c,",")'
          passing 
             xmltype(
                cursor(
                   (select distinct
                       nvl(
                       regexp_substr(
                          access_predicates||' '||filter_predicates
                         ,'("'||alias||'"\.|[^.]|^)"([A-Z0-9#_$]+)"([^.]|$)'
                         ,1
                         ,level
                         ,'i',2
                       ),' ')
                       col
                    from dual
                    connect by 
                       level<=regexp_count(
                                 access_predicates||' '||filter_predicates
                                ,'("'||alias||'"\.|[^.]|^)"([A-Z0-9#_$]+)"([^.]|$)'
                              )
                   )
               ))
          columns cols varchar2(400) path '.'
       )(+)
   order by total_by_cols desc, table_name, cnt desc
)
select 
   table_name
  ,cols
  ,sum(cnt)over(partition by table_name,cols) total_by_cols
  ,access_predicates
  ,filter_predicates
  ,cnt
from cols
where rownum<=50
order by total_by_cols desc, table_name, cnt desc;
