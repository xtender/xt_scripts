accept _mask prompt "Mask[%]: " default '%';
select kqftanam 
from x$kqfta
where lower(kqftanam) like lower(q'[&_mask]')
order by 1;
undef _mask
