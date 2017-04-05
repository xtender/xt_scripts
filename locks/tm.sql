set serverout on;

declare
   locks v$lock%rowtype;
begin
   loop
      for s in ( select s.sid
                        ,s.event
                        --,s.serial#
                        ,s.sql_id
                        ,(select ss.sql_text 
                          from v$sql ss 
                          where ss.sql_id=s.sql_id 
                            and rownum=1
                         ) as sql_text
                        ,s.P1 --name|mode
                        ,s.P1TEXT
                        ,s.p2 --object #
                        ,s.P2TEXT
                        ,s.p3 --table/partition
                        ,s.P3TEXT
                 from   v$session s
                 where  
                        $IF DBMS_DB_VERSION.VERSION=11 $THEN
                           s.EVENT#=234
                        $ELSIF DBMS_DB_VERSION.VERSION=10 $THEN
                           s.event='enq: TM - contention'
                        $ELSE
                           s.event='enq: TM - contention'
                        $END
                         /*
                         event_id      = 668627480
                         name          = 'enq: TM - contention'
                         wait_class_id = 4217450380
                         wait_class#   = 1
                         wait_class    = 'Application'
                         */
                 --and rownum=1
                )
      loop
         dbms_output.put_line(
              'SID='||s.sid
            ||',P1='||s.p1
            ||',P2='||s.p2
            ||',P3='||s.p3
            ||',SQL_ID='||s.sql_id
            ||',Text: '||s.sql_text
         );
         dbms_output.put_line(chr(10));
         dbms_output.put_line(chr(10));
         for locks in (
                        select *
                        from   v$lock l
                        where l.type='TM'
                          and l.id1=s.p2
                      )
         loop
            dbms_output.put_line(
                 'ADDR = '||locks.addr
               ||', kaddr='||locks.kaddr
               ||', sid='||locks.sid
               ||', type='||locks.type
               ||', id1='||locks.id1
               ||', id2='||locks.id2
               ||', lmode='||locks.lmode
               ||', request='||locks.request
               ||', ctime='||locks.ctime
               ||', block='||locks.block
            );
            dbms_output.put_line(chr(10));
            for locker in ( select sb.* 
                                  ,( select st.sql_text 
                                     from v$sql st 
                                     where sb.sql_id=st.sql_id 
                                       and rownum=1
                                   ) as sql_text
                            from v$session sb
                            where sb.sid=locks.sid
                          )
            loop
               dbms_output.put_line(
                  'locker.username='||locker.username
                  ||chr(10)||
                  'locker.program='||locker.program
                  ||chr(10)||
                  'locker.module='||locker.module
                  ||chr(10)||
                  'locker.sql_id='||locker.sql_id
                  ||chr(10)||
                  'locker.sql_text='||locker.sql_text
               );
            end loop;
         end loop;
         dbms_output.put_line('------------');
      end loop;
      --dbms_lock.sleep(10);
      exit;
   end loop;
end;
/

set serverout off;