accept _query prompt "Enter the query: ";
var c clob;
declare
    m_sql_in    clob :=q'[&_query]';
    m_sql_out   clob := empty_clob();
 
begin
    if upper(substr(m_sql_in,1,6))='SELECT' then
		dbms_sql2.expand_sql_text(
			m_sql_in,
			m_sql_out
		);
	else
		dbms_sql2.expand_sql_text(
			'select * from '||m_sql_in,
			m_sql_out
		);
	end if;
    :c:=m_sql_out;
end;
/
print c;