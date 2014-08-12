def _mask='([ ,]?:"SYS_B_\d+")+';
def _min_similarity=90;
accept _sql_id      prompt "Enter sql_id: " default 'n';


col q_text       noprint
col q_normalized noprint
col p_text       noprint
col p_normalized noprint
col prof_name    for a30
col category     for a10
col signature    noprint
col created      noprint
col description  for a40

with
  t1 as (
        select '&_sql_id' as sql_id
          ,coalesce(
                     (select sql_text     from dba_hist_sqltext t where sql_id='&_sql_id')
                    ,(select sql_fulltext from v$sqlarea        a where sql_id='&_sql_id')
                   ) as sql_text
        from dual
        )
 ,t  as (
        select sql_id
              ,sql_text                                              as q_text
              ,regexp_replace(sql_text,'&_mask','...') as q_normalized
        from t1
        where rownum>0
        )
 ,p as (
        select 
               p1.NAME                                               as prof_name
              ,p1.category
              ,p1.signature
              ,p1.sql_text                                           as p_text
              ,regexp_replace(sql_text,'&_mask','...')               as p_normalized
              ,p1.created
              ,p1.last_modified
              ,p1.description
              ,p1.type
              ,p1.status
              ,p1.force_matching
        from dba_sql_profiles p1
        where rownum>0
       )
select 
       t.q_normalized
      ,least   (length(p_normalized),length(q_normalized)) as len_least
      ,greatest(length(p_normalized),length(q_normalized)) as len_greatest
      ,p.* 
      ,utl_match.edit_distance_similarity(
                 substr(p_normalized,1,least(length(p_normalized),length(q_normalized)))
                ,substr(q_normalized,1,least(length(p_normalized),length(q_normalized)))
               ) as similarity

from t, p
where 
       utl_match.edit_distance_similarity(
                 substr(p_normalized,1,least(length(p_normalized),length(q_normalized)))
                ,substr(q_normalized,1,least(length(p_normalized),length(q_normalized)))
               )>&_min_similarity
/
col q_text       clear;
col q_normalized clear;
col p_text       clear;
col p_normalized clear;
col prof_name    clear;
col category     clear;
col signature    clear;
col created      clear;
col description  clear;
undef _sql_id;
undef _mask;
undef _min_similarity;
