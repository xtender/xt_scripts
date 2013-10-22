prompt &_C_REVERSE *** Shows nondefault "_fix_control" parameter &_C_RESET;
col s format a50;
with 
  t as (
        select value fix 
        from v$parameter p 
        where name='_fix_control'
       )
,t1 as (     
        select 
          fix
         ,decode(level,1,1,instr(fix,',',1,level-1)+1) i1
         ,instr(fix,',',1,level) i2
        from t
        connect by level<=length(fix) - length(translate(fix,'.,','.'))+1
)
select trim(substr(fix,i1,decode(i2,0,length(fix),i2-i1))) s
from t1
/
col s clear;
