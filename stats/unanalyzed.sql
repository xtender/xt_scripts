@inc/input_vars_init;
--- additional params:
prompt &_C_REVERSE ****                Show unanalized tables                  ****&_C_RESET
prompt
prompt Syntax: @stats/unanalized [owner_mask] [+temp] [+stale]
prompt By default it shows nontemporary never analyzed tables.
set termout off;
col p_owner         new_value _owner
col if_wo_temp new_value _if_wo_temp
col if_w_stale   new_value _if_w_stale
select 
   case 
      when '&1' is null or substr('&1',1,1)='+'
         then USER
      else upper('&1')
   end p_owner
  ,case 
      when instr(lower('&1 &2 &3 &4'),'+temp')>0  then '--'
      else ''
   end if_wo_temp
  ,case 
      when instr(lower('&1 &2 &3 &4'),'+stale')>0 then ''
      else '--'
   end if_w_stale 
from dual;
set termout on
--- =================
col owner         format a12
col table_name    format a30
col stats_status  format a15
col user_stats    format a9
col part          format a4
col tmp           format a3
col sec           format a3
col nest          format a4
col s_locked      format a8
set colsep " | "

                 select
                     tt.owner
                    ,tt.table_name
                    ,case when tt.LAST_ANALYZED is null then 'not analyzed' else 'stale' end stats_status
                    ,ts.user_stats       as user_stats
                    ,tt.PARTITIONED      as part
                    ,tt.TEMPORARY        as tmp
                    ,tt.secondary        as sec
                    ,tt.nested           as nest
                    ,ts.stattype_locked  as stat_lock
                    ,ts.global_stats
                    ,ts.num_rows
                    ,ts.blocks
                    ,ts.empty_blocks
                    ,tt.last_analyzed 
                 from dba_tables tt
                     ,dba_tab_statistics ts
                 where 
                     tt.owner like nvl(upper('&1'),'%')
                 and tt.owner=ts.owner
                 and tt.table_name=ts.table_name
                 and ts.PARTITION_NAME is null
&_if_wo_temp     and tt.temporary='N'
                 and (
                      tt.LAST_ANALYZED is null
&_if_w_stale       or ts.stale_stats='YES'
                     )
order by 
    tt.owner
   ,case when tt.LAST_ANALYZED is null then 1 else 2 end
   ,tt.table_name
/
@inc/input_vars_undef;
col owner        clear
col table_name   clear
col stats_status clear
col user_stats   clear
col part         clear
col tmp          clear
col sec          clear
col nest         clear
col s_locked     clear
undef _owner
undef _if_wo_temp
undef _if_w_stale