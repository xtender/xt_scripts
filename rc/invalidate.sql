prompt dbms_result_cache.Invalidate(owner,name);
accept owner prompt 'Owner:';
accept name  prompt 'Object name:';
exec dbms_result_cache.Invalidate(upper('&owner'),upper('&name'));