col latch_name      format a15
col WILLING_TO_WAIT format 999.99
col NO_WAIT         format 999.99

select
       name                                    as latch_name
      ,gets
      ,misses
      ,(misses/gets) * 100                     as WILLING_TO_WAIT
      ,immediate_gets
      ,immediate_misses
      ,(immediate_misses/immediate_gets) * 100 as NO_WAIT
from   v$latch
where  name = 'redo copy'
/