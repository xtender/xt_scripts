select o.type,o.status
      ,min(o.CREATION_TIMESTAMP)  min_ts
      ,max(o.CREATION_TIMESTAMP)  max_ts
      ,to_char(min(o.scn),'999g999g999g999') min_scn
      ,to_char(max(o.scn),'999g999g999g999') max_scn
      ,rtrim(scn_to_timestamp_without_err(min(o.scn)),'0') min_t
      ,rtrim(scn_to_timestamp_without_err(max(o.scn)),'0') max_t
      ,count(*)
from v$result_cache_objects o
where o.name like '%DESCCLASS%'
group by o.type,o.status
order by 1,2
/
