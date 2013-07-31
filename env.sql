@inc/input_vars_init;
col sql_feature format a20
select e.INST_ID
      ,e.sid
      ,e.id
      ,e.name
      ,e.sql_feature
      ,e.isdefault
      ,e.value 
from gv$ses_optimizer_env e
where e.sid=nvl('&1',userenv('SID')) 
  and (
           ('&2' is     null and isdefault='NO')
        or ('&2' is not null and upper(name) like upper('%&2%'))
      )
/
col sql_feature clear;
@inc/input_vars_undef;