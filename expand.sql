accept _query prompt "Enter the query: ";

set termout off timing off head off feed off serverout off

var cur refcursor;

declare
    m_sql_in        clob :=q'[&_query]';
    m_sql_out       clob := empty_clob();
    v_sql_splitted  ku$_vcnt;
 
   function f_split( p_txt clob
                   , p_len int
                   , p_delim varchar2
                   ) 
   return ku$_vcnt 
   is
      v_txt   clob:=p_txt;
      v_chunk varchar2(4000);
      v_pos   int;
      v_res   ku$_vcnt:=ku$_vcnt();
      i int:=0;
   begin
      loop
         i:=i+1;
         exit when trim(v_txt) is null or length(trim(v_txt))=0;
         
         if length(v_txt)>p_len then
            v_chunk := substr(v_txt,1,p_len);
            v_pos   := instr(v_chunk, p_delim,-1,1);
            if v_pos = 0 then
               v_pos := p_len;
            end if;
         
            v_chunk := substr(v_chunk,1,v_pos);
            v_txt   := substr(v_txt,v_pos+1);
         else
            v_chunk := v_txt;
            v_txt   := null;
         end if;
         
         v_res.extend;
         v_res(v_res.count):=v_chunk;
            
      end loop;
      return v_res;
   end;
   
   procedure expand_sql_text(p_in clob, p_out in out nocopy clob) is
   begin
      $IF DBMS_DB_VERSION.ver_le_10 $THEN
	     p_out :='Error: Unsupported version!';
      $ELSIF DBMS_DB_VERSION.ver_le_11_2 $THEN
         dbms_sql2.expand_sql_text(p_in,p_out);
      $ELSE
         dbms_utility.expand_sql_text(p_in,p_out);
      $END
   end;

begin
    if upper(substr(m_sql_in,1,6))='SELECT' then
		expand_sql_text(
			m_sql_in,
			m_sql_out
		);
	else
		expand_sql_text(
			'select * from '||m_sql_in,
			m_sql_out
		);
	end if;
	v_sql_splitted := f_split(m_sql_out ,1500,' ');
    open :cur for select column_value qtext from table(v_sql_splitted);
end;
/
col qtext format a32000
prompt ################################  Original query text:  ################################################;
spool &_SPOOLS/to_format.sql
print cur;
spool off
col qtext   clear
undef _query;
set termout on head on feed on
prompt ################################  Formatted query text #################################################;
--host perl inc/sql_format_standalone.pl &_SPOOLS/to_format.sql
host java -jar inc/SQLBeautifier.jar &_SPOOLS/to_format.sql
prompt ################################  Formatted query text End #############################################;
