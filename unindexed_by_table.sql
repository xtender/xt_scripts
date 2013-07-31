set serverout on;
declare

   procedure print_unindexed_by_table( p_owner      in varchar2
                                      ,p_table_name in varchar2
                                     )
   is
      l_cols varchar2(4000);
   begin
      for rec in (
               select c.owner
                    , c.table_name
                    , c.constraint_name
                    , c.cols
               from (
                 select a.owner
                      , a.table_name
                      , a.constraint_name
                      , 
                        $IF DBMS_DB_VERSION.version>=11 and DBMS_DB_VERSION.release>=2 $THEN
                           listagg(b.column_name, ' ' ) within group (order by column_name) --11.2
                        $ELSE
                           cast(collect(b.column_name) as sys.ku$_vcnt)
                        $END
                          cols
                     from dba_constraints a, dba_cons_columns b
                    where a.constraint_name = b.constraint_name
                      and a.owner=b.owner
                      and a.constraint_type = 'R'
                      and a.status='ENABLED'
                 group by a.owner,a.table_name, a.constraint_name
                ) c
                left outer join
                (
                 select i_owner
                      , table_name
                      , index_name
                      , cr
                      , 
                        $IF DBMS_DB_VERSION.version>=11 and DBMS_DB_VERSION.release>=2 $THEN
                           listagg(column_name, ' ') within group (order by column_name) --11.2
                        $ELSE 
                           cast(collect(column_name) as sys.ku$_vcnt) -- 10.2
                        $END
                          cols
                   from (
                       select table_owner i_owner
                            , table_name
                            , index_name
                            , column_position
                            , column_name
                            , connect_by_root(column_name) cr
                         from dba_ind_columns
                      connect by prior column_position-1 = column_position
                             and prior index_name = index_name
                        )
                   group by i_owner,table_name, index_name, cr
               ) i on c.cols = i.cols and c.table_name = i.table_name and c.owner=i.i_owner
               where i.index_name is null
               and c.constraint_name in (
                                          select ccc.constraint_name
                                          from dba_constraints ccc
                                          where ccc.owner=P_OWNER
                                            and ccc.constraint_type='R'
                                            and ccc.r_constraint_name in (
                                                                         select cccc.constraint_name 
                                                                         from dba_constraints cccc
                                                                         where cccc.table_name=P_TABLE_NAME
                                                                         and cccc.owner=P_OWNER
                                                                         )
              )
      )
      loop
         $IF DBMS_DB_VERSION.version>=11 and DBMS_DB_VERSION.release>=2 $THEN
            l_cols:=rec.cols;
         $ELSE
            l_cols:=null;
            for i in rec.cols.first..rec.cols.last loop
               l_cols:=l_cols||','||rec.cols(i);
            end loop;
            l_cols:=ltrim(l_cols,',');
         $END
         /*
         dbms_output.put_line( rec.owner||'.'
                             ||rpad(rec.table_name,30,' ')
                             ||rpad(rec.constraint_name,30,' ')
                             ||l_cols
                             );
                             */
         dbms_output.put_line( 'create index '||rec.owner||'.IX_'
                             ||rec.table_name||'_'
                             ||replace(l_cols,',','')
                             ||' on '||rec.owner||'.'||rec.table_name||'('||l_cols||') tablespace ix_users;'
                             );
      end loop;
   end print_unindexed_by_table;
begin
  print_unindexed_by_table(
    nvl(upper('&table_owner'),'OD')
   ,upper('&table_name')
  );
end;
/
set serverout off;