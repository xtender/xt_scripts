@@show_clients;
@@show_window_clients;

accept _client_name prompt "Enter client name to modify windows: ";

accept MONDAY_WINDOW    prompt "MONDAY_WINDOW      [ENABLE/DISABLE]: ";
accept TUESDAY_WINDOW   prompt "TUESDAY_WINDOW     [ENABLE/DISABLE]: ";
accept WEDNESDAY_WINDOW prompt "WEDNESDAY_WINDOW   [ENABLE/DISABLE]: ";
accept THURSDAY_WINDOW  prompt "THURSDAY_WINDOW    [ENABLE/DISABLE]: ";
accept FRIDAY_WINDOW    prompt "FRIDAY_WINDOW      [ENABLE/DISABLE]: ";
accept SATURDAY_WINDOW  prompt "SATURDAY_WINDOW    [ENABLE/DISABLE]: ";
accept SUNDAY_WINDOW    prompt "SUNDAY_WINDOW      [ENABLE/DISABLE]: ";

BEGIN
  DBMS_AUTO_TASK_ADMIN.&MONDAY_WINDOW    ( client_name => '&_client_name',    operation   => NULL,    window_name => rtrim('MONDAY_WINDOW   '));
  DBMS_AUTO_TASK_ADMIN.&TUESDAY_WINDOW   ( client_name => '&_client_name',    operation   => NULL,    window_name => rtrim('TUESDAY_WINDOW  '));
  DBMS_AUTO_TASK_ADMIN.&WEDNESDAY_WINDOW ( client_name => '&_client_name',    operation   => NULL,    window_name => rtrim('WEDNESDAY_WINDOW'));
  DBMS_AUTO_TASK_ADMIN.&THURSDAY_WINDOW  ( client_name => '&_client_name',    operation   => NULL,    window_name => rtrim('THURSDAY_WINDOW '));
  DBMS_AUTO_TASK_ADMIN.&FRIDAY_WINDOW    ( client_name => '&_client_name',    operation   => NULL,    window_name => rtrim('FRIDAY_WINDOW   '));
  DBMS_AUTO_TASK_ADMIN.&SATURDAY_WINDOW  ( client_name => '&_client_name',    operation   => NULL,    window_name => rtrim('SATURDAY_WINDOW '));
  DBMS_AUTO_TASK_ADMIN.&SUNDAY_WINDOW    ( client_name => '&_client_name',    operation   => NULL,    window_name => rtrim('SUNDAY_WINDOW   '));
END;
/
@@show_window_clients;
