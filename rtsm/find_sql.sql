@inc/input_vars_init
prompt Show only first 30 found:

col sql_id          format a13;
col signature       format a21;
col sql_text_trunc  format a100 word;
col to_purge        format a30;

SELECT/*+NOTME*/ 
       inst_id
     , sa.sql_id
     , sa.sql_exec_start
     , sa.status
     , to_char(sa.force_matching_signature,'tm9')                   as signature
     , sa.sql_plan_hash_value                                       as phv
     , sa.elapsed_time/1e6                                          as elaexe
     , substr(sql_text,1,300)                                       as sql_text_trunc
FROM gv$sql_monitor sa
where
              upper(sa.sql_text) like upper(q'[&1]')
          and sql_text not like 'SELECT/*+NOTME*/%'
          and rownum<=30
order by sa.sql_exec_start desc, elapsed_time desc
/
col sql_id              clear;
col sql_text_trunc      clear;
col to_purge            clear;
