accept ctx_param prompt "Parameter name : ";
accept ctx_value prompt "Parameter value: ";
exec ctxsys.CTX_ADM.SET_PARAMETER('&ctx_param'    ,'&ctx_value');