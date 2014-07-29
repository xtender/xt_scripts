set serverout on feed on;

declare
    cnt1 int;
    cnt2 int;
    
    procedure create_view_and_grant(
                 p_xtab_name varchar
                ,p_user      varchar2
       )
    is
       cnt1 int:=0;
    begin
       select count(*) cnt into cnt1
       from v$fixed_table v
       where v.name = p_xtab_name;

       select count(*) cnt into cnt2
       from dba_views v
       where v.owner='SYS' and v.view_name='V'||p_xtab_name;
                
       if cnt1 = 1 then
          if cnt2 = 1 then
             raise_application_error(-20001,'View V'||p_xtab_name||' already exists.');
          elsif cnt2 = 0 then
             execute immediate 'create or replace force view v'||p_xtab_name||' as select * from SYS.'||p_xtab_name;
             execute immediate 'create public synonym        v'||p_xtab_name||'             for SYS.v'||p_xtab_name;
             execute immediate 'grant select on              v'||p_xtab_name||' to '||p_user;
          end if;
       else
          raise_application_error(-20001,'View '||p_xtab_name||' not exists.');
       end if;
       dbms_output.put_line(rpad(p_xtab_name,31)||': was successfully created');
    exception when others then
       dbms_output.put_line(rpad(p_xtab_name,31)||':'||replace(sqlerrm,chr(10),' '));
    end;
begin
   /* parameters: */
   create_view_and_grant('X$KSPPCV'          ,'PUBLIC');
   create_view_and_grant('X$KSPPI'           ,'PUBLIC');
   create_view_and_grant('X$KSPVLD_VALUES'   ,'PUBLIC');
   /* latches, mutexes, cursors... library cache: */
   create_view_and_grant('X$KGLPN'           ,'PUBLIC');
   create_view_and_grant('X$KGLLK'           ,'PUBLIC');
   create_view_and_grant('X$KSUSE'           ,'PUBLIC');
   create_view_and_grant('X$KGLOB'           ,'PUBLIC');
   create_view_and_grant('X$KSLLD'           ,'PUBLIC');
   create_view_and_grant('X$KSLLTR_CHILDREN' ,'PUBLIC');
   create_view_and_grant('X$KSLLTR_PARENT'   ,'PUBLIC');
   create_view_and_grant('X$KSLLW'           ,'PUBLIC');
   create_view_and_grant('X$KGLCURSOR'       ,'PUBLIC');
   create_view_and_grant('X$KSMHP'           ,'PUBLIC');
   create_view_and_grant('X$KSUPR'           ,'PUBLIC');
   /* latchprofx */
   create_view_and_grant('X$KSUPRLAT'        ,'PUBLIC');
   /* transactions */
   create_view_and_grant('X$KTCXB'           ,'PUBLIC');
   create_view_and_grant('X$K2GTE2'          ,'PUBLIC');
   /* buffer cache */
   create_view_and_grant('X$BH'              ,'PUBLIC');
end;
/
set serverout off feed off;
