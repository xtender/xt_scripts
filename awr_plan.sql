select * 
from 
  table(
    dbms_xplan.display_awr(
         sql_id => '&sql_id'
        ,plan_hash_value => &plan_hash_value
        ,db_id => (select dbid from v$database)
        ,format => 'ADVANCED' 
    )
  );
  