prompt Script for generating ddl text like 'Alter ... compile'
accept do_exec prompt 'Execute?[NO/yes]'
set serverout on;

declare
  
  v_sql      varchar2(32767);
  v_obj_name varchar2(70);
  
  procedure exec(p_sql in varchar2,p_comment in varchar2 default null) is
  begin
     if upper('&do_exec')='YES' then 
        execute immediate p_sql;
     else
        dbms_output.put_line(p_sql||';');
     end if;
  exception when others then
     dbms_output.put_line(p_comment||p_sql||': '||sqlerrm);
  end;
BEGIN
  FOR cur_rec IN (SELECT 
                        'ALTER '
                      ||DECODE(object_type, 'PACKAGE BODY', 'package'
                                          , object_type
                              )
                      ||' '
                      ||'"'||owner      ||'".'
                      ||'"'||object_name||'" '
                      ||'compile' 
                      ||DECODE(object_type, 'PACKAGE BODY', ' body'
                                          , ' '
                              )
                      as v_ddl
                     ,DECODE(object_type, 'PACKAGE'     , 1
                                        , 'PACKAGE BODY', 2
                                        , 'FUNCTION'    , 3
                                        , 'PROCEDURE'   , 4
                                        , 2
                            ) AS recompile_order
                  FROM   dba_objects
                  WHERE  object_type IN ('PROCEDURE', 'FUNCTION','PACKAGE','PACKAGE BODY')
                  and    owner='&owner'
                  AND    status = 'INVALID'
                  ORDER BY recompile_order
                 )
  LOOP
     exec(cur_rec.v_ddl);
  END LOOP;
END;
/
set serverout off;
undef do_exec owner;
