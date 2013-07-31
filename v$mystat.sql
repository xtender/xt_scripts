select
     name
   , value
from
     v$mystat v
   , v$statname s
where
     s.name like '%&name_mask%'
 and s.statistic# = v.statistic#
/