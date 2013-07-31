select 
   parent_name
  ,location
  ,nwfail_count
  ,sleep_count
  ,wtr_slp_count
  ,longhold_count
  ,longhold_count*100/sleep_count pct_longhold

from (
      select l.* 
            ,row_number()over(order by longhold_count desc) rn_long
            ,row_number()over(order by l.WTR_SLP_COUNT desc)    rn_sleep
      from v$latch_misses l
     )
where rn_long<=10 or rn_sleep<=10
order by longhold_count desc
