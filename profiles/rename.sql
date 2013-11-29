prompt &_C_REVERSE *** Profile Renaming &_C_RESET;
accept _old_prof prompt "Old name: "
accept _new_prof prompt "New name: "

exec dbms_sqltune.alter_sql_profile(name => '&_old_prof',attribute_name => 'NAME',value => '&_new_prof');
undef _new_prof _old_prof
