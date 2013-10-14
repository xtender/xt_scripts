@inc/input_vars_init;
col _SEG_OWNER  new_value _SEG_OWNER    noprint;
col _SEG_NAME   new_value _SEG_NAME     noprint;
set termout off timing off
select
  decode(instr('&1','.')
          ,0,nvl('&2','%')
          ,substr('&1',1,instr('&1','.')-1)
        ) "_SEG_OWNER"
 ,decode(instr('&1','.')
          ,0,'&1'
          ,substr('&1',instr('&1','.')+1)
        ) "_SEG_NAME"
from dual;

COL owner           FOR A15
COL segment_name    FOR A30
COL size_mb         FOR A15
COL segment_type    FOR A15
COL segment_subtype FOR A10
set termout on
select
                           s.owner
                          ,s.segment_name
                          ,s.partition_name
                          ,to_char(s.bytes/1024/1024,'999g999g990d9',q'[nls_numeric_characters='. ']') size_mb
                          ,s.blocks
                          ,s.segment_type
    &_IF_ORA11_OR_HIGHER  ,s.segment_subtype
                          ,s.tablespace_name
from dba_segments s
where s.segment_name like upper('&_SEG_NAME')
and s.owner like upper('&_SEG_OWNER')
order by 1,2,3
/
col _SEG_OWNER  clear;
col _SEG_NAME   clear;
undef _SEG_NAME _SEG_OWNER
@inc/input_vars_undef;
