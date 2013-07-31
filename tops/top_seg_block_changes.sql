@inc/input_vars_init;
prompt &_C_REVERSE Print top segments by db block changes &_C_RESET
prompt Syntax:  @top_seg_block_changes [cnt [sleep]]
set serverout on

declare
   C_CNT   constant int := nvl('&1'+0,1);
   C_SLEEP constant int := nvl('&2'+0,3);

   /** formatting */
      L_RN    constant int:=6;
      L_OWNER constant int:=30;
      L_TYPE  constant int:=12;
      L_OBJ   constant int:=32;
      L_DELTA constant int:=12;
   /** local types/variables: */
   type t_lists is table of sys.ku$_objnumpairlist
                         index by pls_integer;
   a_lists t_lists; 
   t sys.ku$_objnumpairlist;
   /** Procedures */
   procedure print_br(p_delim varchar2) is
   begin
      dbms_output.put_line( lpad( p_delim
                                 ,14 + L_RN + L_OWNER + L_TYPE + L_OBJ + L_DELTA 
                                 ,p_delim 
                                )
                          );
   end print_br;
   
   procedure print_line(v_rn varchar2, v_owner varchar2, v_type varchar2, v_obj varchar2, v_delta varchar2) is
   begin
      dbms_output.put_line(  
                      '| ' || lpad( v_rn    ,L_RN   )
                   ||' | ' || rpad( v_owner ,L_OWNER)
                   ||' | ' || lpad( v_type  ,L_TYPE )
                   ||' | ' || rpad( v_obj   ,L_OBJ  )
                   ||' | ' || lpad( v_delta ,L_DELTA)
      );
   end print_line;
   
   procedure print_stat(idx int) is
   begin
      print_br('=');
      print_line('N','Owner','Type','Object','Delta');
      print_br('-');
      
      for r in (
            with deltas as (
                     select 
                         row_number()over(order by a2.num2-nvl(a1.num2,0) desc) rn
                        ,a2.num1                obj#
                        ,a2.num2-nvl(a1.num2,0) delta
                     from table(a_lists(idx-1)) a1
                         ,table(a_lists(idx  )) a2
                     where a1.num1(+)=a2.num1
            )
            select o.owner
                  ,o.object_type
                  ,o.object_name
                  ,deltas.* 
            from   deltas, dba_objects o
            where  o.object_id=deltas.obj#
              and  deltas.rn<=10
            order by rn
      )
      loop
         print_line(r.rn, r.owner, r.object_type, r.object_name, r.delta);
      end loop;
      print_br('=');
   end print_stat;
begin
   -- collect:
   for i in 0..C_CNT loop
      select 
         sys.ku$_objnumpair( st.obj#,sum(st.value))
         bulk collect into a_lists(i)
      from v$segstat st
          ,v$segstat_name sn
      where 
          st.statistic# = sn.statistic#
      and sn.name       = 'db block changes'
      group by st.obj#;

      dbms_lock.sleep(C_SLEEP);
   end loop;
   -- output:   
   for i in 1..C_CNT loop
      print_stat(i);
   end loop;

end;
/
set serverout off
@inc/input_vars_undef
