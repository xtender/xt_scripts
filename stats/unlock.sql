accept _owner prompt "Owner: ";
accept _tname prompt "Table name: ";
call dbms_stats.unlock_table_stats(ownname => upper('&_owner'),tabname => '&_tname');
undef _owner _tname
