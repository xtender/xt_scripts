@inc/input_vars_init;
prompt &_C_REVERSE *** Show text from dba_source by object name: &_C_RESET
prompt *** Usage: @src object_mask [owner_mask]
col owner format a30;
col text  format a80;
set serverout on;
begin
   for r in (  select src.owner,src.name,src.type,src.line,rtrim(src.text,chr(10)) text
                     ,max(length(owner))over() len_owner
                     ,max(length(name))over()  len_name
                     ,max(length(type))over()  len_type
                     ,max(length(text))over()  len_text
               from dba_source src
               where src.owner like nvl('&2','%')
                 and src.name like upper('&1')
            )
   loop
      dbms_output.put_line(
                            rpad(r.owner,r.len_owner) 
                || ' | ' || rpad(r.name ,r.len_name )
                || ' | ' || rpad(r.type ,r.len_type )
                || ' | ' || to_char(r.line,'9999')
                || ' | ' || rpad(r.text ,r.len_text )
      );
   end loop;
end;
/
set serverout off;
col text clear;
@inc/input_vars_undef;
