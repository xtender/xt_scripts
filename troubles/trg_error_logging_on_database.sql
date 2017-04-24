create table sys.ERROR_LOG
(
  id       NUMBER,
  username VARCHAR2(30),
  ip_addr  VARCHAR2(60),
  errcode  INTEGER,
  seq      INTEGER,
  tmstmp   TIMESTAMP(6),
  msg      VARCHAR2(4000),
  sql_text CLOB
)
/
create sequence sys.err_seq
/
create or replace trigger sys.trg_error_logging
after servererror
on database
disable
declare
   v_id       number   := err_seq.nextval();
   v_tmstmp   timestamp:= systimestamp;
   v_ip_addr  varchar2(60);
   n          int;
   sql_text   dbms_standard.ora_name_list_t;
   v_sql_text clob;
   pragma autonomous_transaction;
begin
   if ora_server_error(1) not in (25228) then
   
      v_sql_text:=null;
      v_ip_addr:=ora_client_ip_address();
      n := ora_sql_txt(sql_text);
      for i in 1..n loop
         v_sql_text := v_sql_text || sql_text(i);
      end loop;

      for i in 1.. ora_server_error_depth
      loop
         if i=1 then
            insert into sys.error_log(id,seq,ip_addr,tmstmp,username,errcode,msg,sql_text)
               values( v_id, i, v_ip_addr, v_tmstmp, ora_login_user, ora_server_error(i), ora_server_error_msg(i), v_sql_text);
         else
            insert into sys.error_log(id,seq,ip_addr,tmstmp,username,errcode,msg)
               values( v_id, i, v_ip_addr, v_tmstmp, ora_login_user, ora_server_error(i), ora_server_error_msg(i) );
         end if;
      end loop;
   end if;
   commit;
END;
/
sho error;
accept _ENABLE prompt "Do you want to enable trigger? [y/n]: "
set serverout on;
begin
   if lower('&_ENABLE')='y' then
      execute immediate 'alter trigger sys.trg_error_logging enable';
      dbms_output.put_line('Trigger was enabled');
   else
      dbms_output.put_line('Trigger was enabled');
   end if;
end;
/
set serverout off;