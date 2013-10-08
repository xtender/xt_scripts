prompt *** dbms_result_cache.Invalidate_object(id/cache_id);
select 
    case 
        when translate('&1','x0123456789','x') is null and '&1' is not null 
           then dbms_result_cache.Invalidate_object( &1 )
        when '&1' is null 
           then dbms_result_cache.Invalidate_object('&1')
    end "result"
from dual;