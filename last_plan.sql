select * from table(dbms_xplan.display_cursor('','','allstats last -projection'))
/
