select 
        parno_kspvld_values                             par_no
       ,name_kspvld_values                              par_name
       ,ordinal_kspvld_values                           par_ord_val
       ,value_kspvld_values                             par_val
       ,decode(isdefault_kspvld_values,'TRUE','*',' ')  par_is_default
from sys.x$kspvld_values v 
where upper(v.NAME_KSPVLD_VALUES) like upper('%&1%')
order by par_name,par_ord_val
;