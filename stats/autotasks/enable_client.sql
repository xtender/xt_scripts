@@show_clients;
accept _client_name prompt "Enter client name to enable: ";
BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(
    client_name => '&_client_name',
    operation   => NULL,
    window_name => NULL);
END;
/
undef _client_name;
@@show_clients;
