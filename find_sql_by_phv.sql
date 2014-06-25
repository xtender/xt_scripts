@inc/input_vars_init;
prompt *** Find queries by plan_hash_value.
prompt * Usage: @find_sql_by_phv plan_hash_value
prompt Show only first 30 found:
prompt;
col sql_id          format a13;
col sql_text_trunc  format a100 word;
col to_purge        format a30;
SELECT/*+NOTME*/ 
       inst_id
     , sa.sql_id
     , sa.ADDRESS || ',' || sa.HASH_VALUE                           as to_purge
     , sa.plan_hash_value                                           as phv
     , sa.executions                                                as execs
     , sa.elapsed_time/1e6/decode(sa.executions,0,1,sa.executions)  as elaexe
     , substr(sql_text,1,300)                                       as sql_text_trunc
     , sa.sql_profile
FROM gv$sql sa
where
              sa.plan_hash_value = &1
          and sql_text not like 'SELECT/*+NOTME*/%'
order by elapsed_time desc,executions desc;
col sql_id              clear;
col sql_text_trunc      clear;
col to_purge            clear;
@inc/input_vars_undef;