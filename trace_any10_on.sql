exec dbms_monitor.session_trace_enable( -
             session_id => &sid         -
            ,serial_num => &serial      -
            ,waits      => true         -
            ,binds      => true         -
);
