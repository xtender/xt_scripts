@inc/input_vars_init;
col p1text format a40;
col p1      format tm9;
with t as (
        select 
             event
            ,dense_rank()over(partition by event order by count(*) desc) rnk
            ,h.p1text
            ,h.p1
            ,count(*) cnt
        from v$session_wait_history h
        where lower(h.event) like lower('%&1%')
        group by event,p1text,h.p1
)
select *
from t
where rnk<=nvl('&2'+0,5)
order by event,rnk,cnt desc
/
@inc/input_vars_undef;