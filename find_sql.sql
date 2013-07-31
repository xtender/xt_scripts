@inc/input_vars_init
col if_all new_val _if_all noprint;
select case when '&2 &3 &4 &5' like '%all%' then '--'
            else '  '
       end if_all
from dual;
col sql_text_trunc  format a100 word;
col to_purge        format a30;
SELECT/*+NOTME*/ 
       sa.sql_id
     , sa.ADDRESS || ',' || sa.HASH_VALUE                           as to_purge
     , sa.plan_hash_value                                           as phv
     , sa.executions                                                as execs
     , sa.elapsed_time/1e6/decode(sa.executions,0,1,sa.executions)  as elaexe
     , substr(sql_text,1,300)                                       as sql_text_trunc
FROM v$sql sa
where
              upper(sa.sql_text) like upper('%&1%')
          and sql_text not like 'SELECT/*+NOTME*/%'
&_if_all  and sa.COMMAND_TYPE=3
order by elapsed_time desc,executions desc
/
undef _if_all;
col sql_text_trunc      clear;
col to_purge            clear;
