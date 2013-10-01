select * 
from v$indexed_fixed_column
where table_name='&1'
/