set feed off serverout off

var cur refcursor;

declare
   v_sql clob;
   v_sql_splitted ku$_vcnt;
   
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
            v_pos   := instr(v_chunk, chr(10));
            if v_pos = 0 then 
               v_pos   := instr(v_chunk, p_delim,-1,1);
               if v_pos = 0 then
                  v_pos := p_len;
               end if;
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
begin
   select
       coalesce(
           (select sql_fulltext from gv$sqlarea a where a.sql_id='&1' and rownum=1)
       ,   (select sql_text from dba_hist_sqltext a where a.sql_id='&1' and a.dbid in (select dbid from dba_hist_database_instance))
       ) qtext
       into v_sql
   from dual;
   
   v_sql_splitted := f_split(v_sql,250,' ');

   open :cur for select column_value qtext from table(v_sql_splitted);
exception when others then dbms_output.put_line(sqlerrm);
end;   
/

col qtext format a32000
prompt ################################  Original query text:  ################################################;
print cur
col qtext   clear
prompt ################################  Original query text End #############################################;
