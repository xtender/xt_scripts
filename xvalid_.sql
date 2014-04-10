col PAR_NAME        format a40 heading "Name";
col PAR_VAL         format a30 heading "Value"; 
col par_is_default  format a8  heading "Default?";

select 
        parno_kspvld_values        par_no
       ,name_kspvld_values         par_name
       ,ordinal_kspvld_values      par_ord_val
       ,value_kspvld_values        par_val
       ,isdefault_kspvld_values    par_is_default
from sys.x$kspvld_values v 
where upper(v.NAME_KSPVLD_VALUES) like upper('%&1%')
order by par_name,par_ord_val
;
col PAR_NAME clear;
col PAR_VAL  clear;
col par_is_default clear;