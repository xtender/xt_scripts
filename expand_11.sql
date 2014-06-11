var c clob
accept _query prompt "Enter query: ";
exec dbms_sql2.expand_sql_text(q'[&_query]',:c);
print :c;
undef _query;