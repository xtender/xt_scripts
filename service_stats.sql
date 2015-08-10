col statname for a30;

col service1 for a20;
col service2 for a20;
col service3 for a20;
col service4 for a20;
col service5 for a20;
col service6 for a20;
col service7 for a20;
col service8 for a20;
col service9 for a20;

with 
services as (
  select
      max(decode(sn,1,service_name)) service1
     ,max(decode(sn,2,service_name)) service2
     ,max(decode(sn,3,service_name)) service3
     ,max(decode(sn,4,service_name)) service4
     ,max(decode(sn,5,service_name)) service5
     ,max(decode(sn,6,service_name)) service6
     ,max(decode(sn,7,service_name)) service7
     ,max(decode(sn,8,service_name)) service8
     ,max(decode(sn,9,service_name)) service9
   from (
      select service_name
            ,row_number()over(order by value desc) sn
      from v$service_stats
      where stat_name = 'DB time'
   )
)
,s_stats as (
   select stat_name, service_name, value
   from v$service_stats 
   where stat_name in ('logons cumulative','DB time')
)
select 
   '##############################' statname
  ,lpad(service1,20)                service1
  ,lpad(service2,20)                service2
  ,lpad(service3,20)                service3
  ,lpad(service4,20)                service4
  ,lpad(service5,20)                service5
  ,lpad(service6,20)                service6
  ,lpad(service7,20)                service7
  ,lpad(service8,20)                service8
  ,lpad(service9,20)                service9
from services 
union all
select
   stat_name
  ,to_char(max(decode(service_name,service1,value)),'999g999g999g999g990') service1
  ,to_char(max(decode(service_name,service2,value)),'999g999g999g999g990') service2
  ,to_char(max(decode(service_name,service3,value)),'999g999g999g999g990') service3
  ,to_char(max(decode(service_name,service4,value)),'999g999g999g999g990') service4
  ,to_char(max(decode(service_name,service5,value)),'999g999g999g999g990') service5
  ,to_char(max(decode(service_name,service6,value)),'999g999g999g999g990') service6
  ,to_char(max(decode(service_name,service7,value)),'999g999g999g999g990') service7
  ,to_char(max(decode(service_name,service8,value)),'999g999g999g999g990') service8
  ,to_char(max(decode(service_name,service9,value)),'999g999g999g999g990') service9
from services,s_stats
group by stat_name
order by 1
/
col service1 clear;
col service2 clear;
col service3 clear;
col service4 clear;
col service5 clear;
col service6 clear;
col service7 clear;
col service8 clear;
col service9 clear;
col statname clear;
