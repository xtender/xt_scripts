@inc/input_vars_init;

set head off arrays 2

col f format a80

select t.column_value as f
from 
  table(
    xt_slideshow(
        sqltext => q'[&1]'
       ,p_count => nvl('&2'+0,10)
       ,p_pause => nvl('&3'+0,500)
       ,p_len   => nvl('&4'+0,80)
    )
  ) t;

col f clear;
@inc/input_vars_undef;