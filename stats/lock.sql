accept _owner prompt "Owner: ";
accept _tname prompt "Table name: ";
call dbms_stats.lock_table_stats(ownname => upper('&_owner'),tabname => '&_tname');
undef _owner _tname
