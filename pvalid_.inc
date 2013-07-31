select
    name_kspvld_values,
    decode(
        isdefault_kspvld_values,
            'TRUE',  '***',
            'FALSE', null,
                     '?'
    )   isdefault_kspvld_values,
    value_kspvld_values
from
    sys.x$kspvld_values
where name_kspvld_values like '%&1%' escape '\'
order by
    name_kspvld_values,
    ordinal_kspvld_values;
