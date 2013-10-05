set serverout on;
---------------------------------
prompt Creating directory TRACE_DIR for user_dump_dest...;
declare
  l_dir     varchar2(4000);
begin
  select p.value into l_dir from v$parameter p where p.NAME='user_dump_dest';
  execute immediate 'create or replace directory TRACE_DIR as '''||l_dir||'''';
  execute immediate 'grant read on directory TRACE_DIR to public';
  dbms_java.grant_permission( user, 'SYS:java.io.FilePermission', l_dir, 'read' );
  dbms_output.put_line('Directory TRACE_DIR created: '||l_dir);
end;
/
---------------------------------
prompt Java function for directory list...;
create or replace and compile java source named xt_dir as
package org.orasql;

/* Imports */
import java.io.File;
import java.sql.*;
import oracle.sql.*;
import oracle.jdbc.driver.OracleDriver;
import java.util.ArrayList;
import java.util.List;
/* Main class */
public class XT_DIR
{
  public static oracle.sql.ARRAY dirList (String path)
    throws SQLException
  {
      File dir = new File(path);
      List<String> nameList = new ArrayList<String>();
      for(File f:dir.listFiles()){
          System.out.printf("%s    %d\n", f.getName(),f.length());
          nameList.add(f.getName());
      }
      Connection conn = new OracleDriver().defaultConnection();
      ArrayDescriptor descriptor = ArrayDescriptor.createDescriptor("SYS.KU$_VCNT", conn );
      oracle.sql.ARRAY outArray = new oracle.sql.ARRAY(descriptor,conn,nameList.toArray());
      return outArray;
  }
}
/
---------------------------------
prompt Creating package XT_TRACES...;

create or replace package xt_traces as

    function get_trace(f_name varchar2)
        return sys.ku$_vcnt pipelined;
    
    function get_dir_list(path varchar2)
      return sys.ku$_vcnt
      IS LANGUAGE JAVA
      name 'org.orasql.XT_DIR.dirList(java.lang.String) return oracle.sql.ARRAY';
    
    function get_trace_dir_list
      return sys.ku$_vcnt;

end xt_traces;
/
create or replace package body xt_traces as
      
      
    function get_trace(f_name varchar2) 
      return sys.ku$_vcnt pipelined
    as
      f utl_file.file_type;
      s varchar2(4000);
    begin
      f := utl_file.fopen('TRACE_DIR',f_name,'R');
      loop
        begin
          utl_file.get_line(f,s,4000);
          pipe row(s);
        exception 
          when no_data_found then exit;
        end;
      end loop;
      utl_file.fclose(f);
    exception 
      when NO_DATA_NEEDED 
        then utl_file.fclose(f);
    end;
    
    function get_trace_dir_list
      return sys.ku$_vcnt
    as
      l_dir     varchar2(4000);
    begin
      select p.value into l_dir from v$parameter p where p.NAME='user_dump_dest';
      return get_dir_list(l_dir);
    end;
end xt_traces;
/
sho err;
---------------------------------
prompt Grant and synonym...
grant execute on xt_traces to public;
create public synonym xt_traces for xt_traces;
prompt Finished!;
set serverout off;
