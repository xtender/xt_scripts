set serverout on;
@inc/input_vars_init;
prompt &_C_REVERSE *** Show execution plan through DBMS_XPLAN.DISPLAY for RAC *** &_C_RESET.
prompt &_C_BOLD * Syntax: @gplan sql_id &_C_RESET[format]
prompt 
declare 
   v_prefix constant varchar2(1)   := chr(160);
   v_delim  constant varchar2(300) := '================================================';

   procedure print(v varchar2) is
   begin
      dbms_output.put_line( v_prefix || v );
   end;
   
   procedure gdisplay(
                      statement_id varchar2
                     ,format       varchar2 default 'TYPICAL'
                     )
   is
   begin
     for i in (select distinct inst_id, CHILD_NUMBER
                 from gv$sql_plan_statistics_all
                where sql_id = statement_id
                order by 1, 2
              )
     loop
       print( 'INSTANCE#    = ' || i.inst_id );
       print( 'CHILD_NUMBER = ' || i.CHILD_NUMBER );
       for j in (select *
                   from table(dbms_xplan.display('gv$sql_plan_statistics_all',
                                                 null,
                                                 format,
                                                 'inst_id=' || i.inst_id ||
                                                 ' and sql_id=''' ||
                                                 statement_id ||
                                                 ''' and CHILD_NUMBER=' ||
                                                 i.CHILD_NUMBER))
                ) 
       loop
         print( j.plan_table_output );
       end loop;
       print( v_delim );
     end loop;
   end;
begin
   gdisplay('&1','&2');
end;
/
@inc/input_vars_undef;
set serverout off;
