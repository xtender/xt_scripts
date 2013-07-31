select location, sleep_count, wtr_slp_count, longhold_count
from v$latch_misses
where parent_name='Result Cache: Latch'
 and sleep_count+wtr_slp_count+longhold_count > 0;