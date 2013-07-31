col name            format a30;
col value_string    format a80;
col datatype_string format a20;
col elaexe          format a12;
break on snap_id on plan_hv on elaexe on last_captured skip 1;
PROMPT *            &_C_RED *** Binds values from AWR *** &_C_RESET;
with snaps as (
     select distinct snap_id,instance_number,plan_hv,elaexe
     from
        (select st.snap_id                                                           snap_id
               ,st.instance_number                                                   instance_number
               ,st.plan_hash_value                                                   plan_hv
               ,decode(executions_delta,0,null,to_char(st.elapsed_time_delta/1e6/st.executions_delta,'999990.9990')) elaexe
         from dba_hist_sqlstat st 
         where st.sql_id = '&1' 
           and st.dbid   = &DB_ID
         order by snap_id desc
        )
     where rownum<=10
)
select--+ leading(snaps b) use_nl(snaps b)
       s.snap_id
      ,s.plan_hv
      ,s.elaexe
      ,b.last_captured
      ,b.position
      ,b.name
      ,b.value_string
      ,b.datatype_string
from snaps s
    ,dba_hist_sqlbind b
where sql_id            = '&1'
  and b.snap_id         = s.snap_id
  and b.instance_number = s.instance_number
  and b.dbid            = &DB_ID
  and b.dup_position is null
order by b.snap_id,s.plan_hv,s.elaexe,b.last_captured,b.position
/
col name            clear;
col value_string    clear;
col datatype_string clear;
clear break
