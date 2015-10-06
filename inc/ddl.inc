var c clob;
exec :c := dbms_metadata.get_ddl('&3','&2','&1');
print c;