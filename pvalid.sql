column  name		format a30  heading "Name"
column  valid_vals 	format a30  heading "Valid values"
column  opt format a30   heading "Option"

break on name skip 1 page

select 
       curr.name
      ,ordinal N
      ,valid.value valid_vals
     , decode(valid.isdefault,'TRUE','default ')
     ||decode(valid.value,curr.value,'current ')
     as opt
from
     v$parameter curr
    ,v$parameter_valid_values valid 
where upper(curr.name) like upper('%&1%')
and valid.NUM=curr.NUM
order by 
   curr.name
  ,ordinal
  ,regexp_replace(
            regexp_replace(valid.value,'(\d+)','00000\1')
           ,'0+(\d{3})'
           ,'\1'
           );