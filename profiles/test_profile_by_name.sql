var cCur refcursor;

declare
   cSQL clob;
begin
   select p.sql_text into cSQL from dba_sql_profiles p where p.name='&profile';
   
   open :cCur for cSQL;
end;
/
print cCur;
   
