col do_next new_val do_next noprint;
select
      case
         when &1 = &switch_param then 'inc/null'
         else 'inc/comment_on'
      end as do_next
from dual;
@&do_next
