doc 
   OPTIONS:
    *  GATHER: Gathers statistics on all objects in the schema.
    *  GATHER AUTO: Gathers all necessary statistics automatically. 
                    Oracle implicitly determines which objects need new statistics, and determines how to gather those statistics. 
                    When GATHER AUTO is specified, the only additional valid parameters are stattab, statid, objlist and statown; 
                    all other parameter settings are ignored. Returns a list of processed objects.
    *  GATHER STALE: Gathers statistics on stale objects as determined by looking at the *_tab_modifications views. Also, return a list of objects found to be stale.
    *  GATHER EMPTY: Gathers statistics on objects which currently have no statistics. Return a list of objects found to have no statistics.
    *  LIST AUTO: Returns a list of objects to be processed with GATHER AUTO.
    *  LIST STALE: Returns a list of stale objects as determined by looking at the *_tab_modifications views.
    *  LIST EMPTY: Returns a list of objects which currently have no statistics.
#

accept tab_owner - 
       prompt 'Enter value for owner mask[&_USER]: ' -
       default '&_USER';

accept _OPTIONS            prompt 'Options[gather auto]: ' default 'gather auto';
accept _CASCADE            prompt 'CASCADE [TRUE]      : ' default 'true';
accept _DEGREE             prompt 'DEGREE              : ';
accept _ESTIMATE_PERCENT   prompt 'ESTIMATE_PERCENT    : ';
accept _METHOD_OPT         prompt 'METHOD_OPT          : ';
accept _GRANULARITY        prompt 'GRANULARITY[ALL]    : ' default 'ALL';
--accept _NO_INVALIDATE      prompt 'NO_INVALIDATE   : ';

set serverout on;
rem ==================================================================;
declare
    obj_list sys.dbms_stats.ObjectTab;
    
    l integer:=dbms_utility.get_time();
    
    procedure print(v in varchar2) is
    begin
      dbms_output.put_line(to_char((dbms_utility.get_time-l)/100,'0999.99')||' '||v);
      l:=dbms_utility.get_time();
    end;
    
    procedure log_stats_op(
                          p_oper    varchar2
                         ,p_object  sys.dbms_stats.ObjectElem
                         ) 
    is
    begin
       dbms_output.put_line(p_oper||' '
                              ||p_object.ownname||'.'||p_object.ObjName||':'
                                 ||'tp['     || p_object.objtype    ||']'
                                 ||'part['   || p_object.partname   ||']'
                                 ||'subpart['|| p_object.subpartname||']'
                           );
    end;
begin
   for r in (
             select u.username
             from dba_users u
             where u.username   like upper('&tab_owner')
   )
   loop
      print('Starting gather on schema: '||r.username);

      dbms_stats.gather_schema_stats( 
                  ownname => r.username
                , objlist          => obj_list
                , options          => '&&_OPTIONS'
                , degree           => '&&_DEGREE'
                , cascade          => &&_CASCADE
                , estimate_percent => '&&_ESTIMATE_PERCENT'
                , method_opt       => '&&_METHOD_OPT'  --'FOR ALL COLUMNS SIZE SKEWONLY'
                , granularity      => nvl('&&_GRANULARITY','ALL')
                , block_sample     => true
                , gather_temp     => false
                , gather_fixed    => false
               );

      print('Stats gathered on schema '||r.username);

      for i in 1..obj_list.count loop
         log_stats_op( to_char(i,'999')||' '
                     , obj_list(i) 
                     );
      end loop;
                     
   end loop;
end;
/
set serverout off;
