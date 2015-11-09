prompt *** Show tables analyzed though dynamic sampling.
prompt * Usage: @dynamic_sampling_used_for [-temp]

@inc/input_vars_init;

col owner         for a30;
col tab_name      for a30;
col top_sql_id    for a13;
col temporary     for a9;
col last_analyzed for a30;
col partitioned   for a11;
col nested        for a6;
col IOT_TYPE      for a15;
with tabs as (
      select 
&_IF_ORA11_OR_HIGHER          to_char(regexp_substr(sql_fulltext,'FROM "([^"]+)"."([^"]+)"',1,1,null,1))  owner
&_IF_ORA11_OR_HIGHER         ,to_char(regexp_substr(sql_fulltext,'FROM "([^"]+)"."([^"]+)"',1,1,null,2))  tab_name
&_IF_LOWER_THAN_ORA11         regexp_substr(to_char(regexp_substr(sql_fulltext,'FROM "([^"]+"."[^"]+)"',1,1,null)),'"[^"]+"')  owner
&_IF_LOWER_THAN_ORA11        ,regexp_substr(to_char(regexp_substr(sql_fulltext,'FROM "([^"]+"."[^"]+)"',1,1,null)),'"[^"]+"$')  tab_name
        ,count(*)                                                                    cnt
        ,sum(executions)                                                             execs
        ,round(sum(elapsed_time/1e6),3)                                              elapsed
        ,max(sql_id) keep(dense_rank first order by elapsed_time desc)               top_sql_id
      from v$sqlarea a
      where a.sql_text like 'SELECT /* OPT_DYN_SAMP */%'
      group by
&_IF_ORA11_OR_HIGHER          to_char(regexp_substr(sql_fulltext,'FROM "([^"]+)"."([^"]+)"',1,1,null,1))
&_IF_ORA11_OR_HIGHER         ,to_char(regexp_substr(sql_fulltext,'FROM "([^"]+)"."([^"]+)"',1,1,null,2))
&_IF_LOWER_THAN_ORA11         regexp_substr(to_char(regexp_substr(sql_fulltext,'FROM "([^"]+"."[^"]+)"',1,1,null)),'"[^"]+"')
&_IF_LOWER_THAN_ORA11        ,regexp_substr(to_char(regexp_substr(sql_fulltext,'FROM "([^"]+"."[^"]+)"',1,1,null)),'"[^"]+"$')
)
select tabs.* 
      ,t.temporary
      ,t.last_analyzed
      ,t.partitioned
      ,t.nested
      ,t.IOT_TYPE
from tabs
    ,dba_tables t
where 
     tabs.owner    = t.owner(+)
 and tabs.tab_name = t.table_name(+)
 and (decode(upper('&1'),'-TEMP',t.temporary,'N')='N')
order by elapsed desc
/
col owner         clear;
col tab_name      clear;
col top_sql_id    clear;
col temporary     clear;
col last_analyzed clear;
col partitioned   clear;
col nested        clear;
col IOT_TYPE      clear;

@inc/input_vars_undef;