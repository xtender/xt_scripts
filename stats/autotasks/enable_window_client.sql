@@show_clients;
@@show_window_clients;
accept _client_name prompt "Enter client name to enable: ";
accept _window_name prompt "Enter window name to enable: ";
BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(
    client_name => '&_client_name',
    operation   => NULL,
    window_name => '&_window_name');
END;
/
undef _client_name;
undef _window_name;
@@show_clients;
