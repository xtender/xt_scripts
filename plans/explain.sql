explain plan for &sql_text
/
select * from table(dbms_xplan.display(NULL,NULL,'ALL ALIAS'))
/