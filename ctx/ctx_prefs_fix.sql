select /*+ ORDERED INDEX(dr$preference_value) */
  u.name prv_owner
 ,pre_name prv_preference
 ,oat_name prv_attribute
 --,decode(oat_datatype, 'B', decode(prv_value, 1, 'YES', 'NO'), nvl(oal_label, prv_value)) prv_value
 ,prv_value
-- ,drv.prv_pre_id
 ,drv.*
 --,decode(prv_value, 1, 'YES', 'NO')
from
  sys."_BASE_USER" u
 ,ctxsys.dr$preference
 ,ctxsys.dr$preference_value drv
 ,ctxsys.dr$object_attribute
 ,ctxsys.dr$object_attribute_lov
where prv_value = nvl(oal_value, prv_value)
  and oat_id = oal_oat_id (+)
  and oat_id = prv_oat_id
  and prv_pre_id = pre_id
  and pre_owner# = u.user#
and oat_datatype= 'B'
/
select * from ctxsys.dr$preference_value where pre_name like 'CTXSYS.%';
/
update ctxsys.dr$preference set pre_name = regexp_replace(pre_name, 'CTXSYS\.', '') where pre_name like 'CTXSYS.%';
update  ctxsys.dr$preference_value set prv_value='1' where prv_pre_id in (1672,1666) and prv_oat_id=60111;
