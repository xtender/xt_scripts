var c clob
exec dbms_utility.expand_sql_text(q'[&1]',:c);
print :c;