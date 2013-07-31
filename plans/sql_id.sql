select * from table(dbms_xplan.display_cursor('&sql_id',&plan_hash_value,'&params'))
/