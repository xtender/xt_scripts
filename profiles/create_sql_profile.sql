----------------------------------------------------------------------------------------
--
-- File name:   create_sql_profile.sql
--
-- Purpose:     Create SQL Profile based on Outline hints in V$SQL.OTHER_XML.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for four values.
--
--              sql_id: the sql_id of the statement to attach the profile to (must be in the shared pool)
--
--              child_no: the child_no of the statement from v$sql
--
--              profile_name: the name of the profile to be generated
--
--              category: the name of the category for the profile
--
--              force_macthing: a toggle to turn on or off the force_matching feature
--
-- Description: 
--
--              Based on a script by Randolf Giest.
--
-- Mods:        This is the 2nd version of this script which removes dependency on rg_sqlprof1.sql.
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--

-- @rg_sqlprof1 '&&sql_id' &&child_no '&&category' '&force_matching'

set feedback off

accept sql_id -
       prompt 'Enter value for sql_id: ' -
       default 'X0X0X0X0'
accept child_no -
       prompt 'Enter value for child_no (0): ' -
       default '0'
accept profile_name -
       prompt 'Enter value for profile_name (PROF_sqlid_planhash): ' -
       default 'X0X0X0X0'
accept category -
       prompt 'Enter value for category (DEFAULT): ' -
       default 'DEFAULT'
accept force_matching -
       prompt 'Enter value for force_matching (FALSE): ' -
       default 'false'

declare
       ar_profile_hints sys.sqlprof_attr;
       cl_sql_text clob;
       l_profile_name varchar2(30);
begin
       select
              extractvalue(value(d), '/hint') as outline_hints
              bulk collect into ar_profile_hints
       from
              xmltable('/*/outline_data/hint'
                     passing (
                            select
                                   xmltype(other_xml) as xmlval
                            from
                                   v$sql_plan
                            where
                                   sql_id = '&&sql_id'
                                   and child_number = &&child_no
                                   and other_xml is not null
                            )
                     ) d;

       select
              sql_fulltext, 
              decode('&&profile_name','X0X0X0X0','PROF_&&sql_id'||'_'||plan_hash_value,'&&profile_name')
       into
              cl_sql_text, l_profile_name
       from
              v$sql
       where
              sql_id = '&&sql_id'
              and child_number = &&child_no;

       dbms_sqltune.import_sql_profile(
              sql_text => cl_sql_text,
              profile => ar_profile_hints,
              category => '&&category',
              name => l_profile_name,
              force_match => &&force_matching
              -- replace => true
       );

       dbms_output.put_line(' ');
       dbms_output.put_line('SQL Profile '||l_profile_name||' created.');
       dbms_output.put_line(' ');

exception
when NO_DATA_FOUND then
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||'&&sql_id'||' Child: '||'&&child_no'||' not found in v$sql.');
  dbms_output.put_line(' ');

end;
/

undef sql_id
undef child_no
undef profile_name
undef category
undef force_matching

set feedback on