select
   (select value from V$OSSTAT where stat_name='LOAD'    ) load
  ,(select value from V$OSSTAT where stat_name='NUM_CPUS') num_cpus
from dual;