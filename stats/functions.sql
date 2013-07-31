create function raw_to_num(i_raw raw)
return number
as
	m_n number;
begin
	dbms_stats.convert_raw_value(i_raw,m_n);
	return m_n;
end;
/

create function raw_to_date(i_raw raw)
return date
as
   m_n date;
begin
   dbms_stats.convert_raw_value(i_raw,m_n);
   return m_n;
end;
/

create function raw_to_varchar2(i_raw raw)
return varchar2
as
   m_n varchar2(20);
begin
   dbms_stats.convert_raw_value(i_raw,m_n);
   return m_n;
end;
/
