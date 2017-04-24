create table ERROR_LOG
(
  id       NUMBER,
  username VARCHAR2(30),
  errcode  INTEGER,
  seq      INTEGER,
  tmstmp   TIMESTAMP(6),
  msg      VARCHAR2(4000),
  sql_text CLOB
)
/
create sequence err_seq
/
create or replace trigger trg_error_logging
after servererror
on schema
disabled
declare
   v_id       number   := err_seq.nextval();
   v_tmstmp   timestamp:= systimestamp;
   n          int;
   sql_text   dbms_standard.ora_name_list_t;
   v_sql_text clob;
begin
   v_sql_text:=null;
   n := ora_sql_txt(sql_text);
   for i in 1..n loop
      v_sql_text := v_sql_text || sql_text(i);
   end loop;

   for i in 1.. ora_server_error_depth
   loop
      if i=1 then
         insert into error_log(id,seq,tmstmp,username,errcode,msg,sql_text)
            values( v_id, i, v_tmstmp, user, ora_server_error(i), ora_server_error_msg(i), v_sql_text);
      else
         insert into error_log(id,seq,tmstmp,username,errcode,msg)
            values( v_id, i, v_tmstmp, user, ora_server_error(i), ora_server_error_msg(i) );
      end if;
   end loop;
   commit;
END;
/
alter trigger trg_error_logging enable
/
