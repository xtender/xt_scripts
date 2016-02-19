col value for 99999990.99 JUSTIFY RIGHT;
select p.name
      ,case 
           when p.unit='bytes' then 
              case 
                when p.value>1024*1024*1024 then round(p.value/(1024*1024*1024),2)
                when p.value>     1024*1024 then round(p.value/(     1024*1024),2)
                when p.value>          1024 then round(p.value/(          1024),2)
                else p.value
              end
           when p.unit='percent' then p.value
           else p.value
       end value
      ,case 
           when p.unit='bytes' then 
              case 
                when p.value>1024*1024*1024 then ' GB'
                when p.value>     1024*1024 then ' MB'
                when p.value>          1024 then ' KB'
                else                             ' B'
              end
           when p.unit='percent' then ' %'
           else p.unit
       end unit
      ,p.value as original_val
      ,p.unit  as original_units
from v$pgastat p;
col value clear;
