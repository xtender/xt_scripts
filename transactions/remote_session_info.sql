create or replace function remote_session_info(psid int default null) 
   return varchar2 
as
   lsid int;
   res varchar2(4000);
   
   function get_from_remote(remote_db varchar2, host varchar2, globalid varchar2)
      return varchar2
   is
      lres varchar2(4000);
   begin
      execute immediate q'[
            select listagg('{sid='||s.sid||',osuser='||s.osuser||',machine='||s.machine||',client_info='||s.client_info, '}')
            within group(order by 1)
            from v$xt_global_transaction@]'|| remote_db ||q'[ tr
                ,v$session              @]'|| remote_db ||q'[ s
            where tr.saddr=s.saddr
              and nvl2(replace(tr.branchid,'0'),'FROM REMOTE','TO REMOTE') = 'TO REMOTE'
              and tr.globalid=']'||globalid||q'[']'
        into lres;
        return lres;
   exception
      when others then return 'err:'||sqlcode;
   end;
begin
   lsid:=nvl(psid,userenv('sid'));
   for r in (
            select s.sid, s.osuser, s.machine, s.client_info
                  ,tr.globalid
                  ,tr.globalid_ora
                  ,nvl2(replace(tr.branchid,'0'),'FROM REMOTE','TO REMOTE')               as direction
                  ,regexp_replace(tr.globalid_ora,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\1')  as remote_db
                  ,to_number(hextoraw(reverse(regexp_replace(tr.globalid_ora,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\2'))),'XXXXXXXXXXXX') as remote_dbid
            from v$xt_global_transaction tr
                ,v$session s
            where tr.saddr=s.saddr
              and s.sid = lsid
            )
   loop
      res:=res
          ||'  sid='         || r.sid
          ||', osuser='      || r.osuser
          ||', client_info=' || r.client_info
          ||', direction='   || r.direction
          ||', remote_db='   || r.remote_db
          ||', osuser='      || r.osuser
          ||', remote_info=['||get_from_remote(r.remote_db,r.machine,r.globalid)
          ||']';
   end loop;
   return res;
end;
/
