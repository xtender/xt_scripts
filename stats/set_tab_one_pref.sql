set feed on
accept _owner  prompt "Table owner: ";
accept _tname  prompt "Table name : ";

prompt ======================================;
prompt Old preferences: ;
@@tab_prefs "&_tname" "&_owner"

prompt ======================================;
accept _pname  prompt "Pref. param: ";
accept _pvalue prompt "Pref. value: ";

call dbms_stats.set_table_prefs(ownname => upper('&_owner'),tabname => upper('&_tname'),pname => '&_pname',pvalue => '&_pvalue');

prompt ======================================;
prompt New preferences: ;
@@tab_prefs "&_tname" "&_owner"

undef _owner _tname _pname _pvalue
