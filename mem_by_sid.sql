def _sid = &1
col sample_time for a12;
select to_char(h.sample_time,'hh24:mi:ss.FF3') as sample_time
     , h.pga_allocated
     , h.temp_space_allocated
from v$active_session_history h 
where h.session_id=1169 
  and h.sample_time>systimestamp - interval '10' second
order by 1
/
select 
  max(decode(sn.name,'session uga memory'    ,st.value)) UGA
 ,max(decode(sn.name,'session uga memory max',st.value)) UGA_MAX
 ,max(decode(sn.name,'session pga memory'    ,st.value)) PGA
 ,max(decode(sn.name,'session pga memory max',st.value)) PGA_MAX
from v$sesstat st
    ,v$statname sn
where sid=&_sid
and st.statistic#=sn.STATISTIC#
and sn.name like 'session _ga memory%'
group by sid
/
undef _sid;
col sample_time clear;
