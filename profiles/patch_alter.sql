prompt ***************************************************************;
prompt Alter SQL Patch;
doc 
  -- NAME: alter_sql_patch - alter a SQL patch attribute
  -- PURPOSE: This procedure alters specific attributes of an existing
  --          SQL patch object.  The following attributes can be altered
  --          (using these attribute names):
  --            "STATUS" -> can be set to "ENABLED" or "DISABLED"
  --            "NAME"   -> can be reset to a valid name (must be
  --                        a valid Oracle identifier and must be
  --                        unique).
  --            "DESCRIPTION" -> can be set to any string of size no
  --                             more than 500
  --            "CATEGORY" -> can be reset to a valid category name (must
  --                          be valid Oracle identifier and must be unique
  --                          when combined with normalized SQL text)
#
prompt ***************************************************************;

set feed on serverout on;

accept p_name       prompt "Patch name: ";
accept p_attr       prompt "Attribute: ";
accept p_value      prompt "Value: ";


declare
   -- params:
   p_name           varchar2(30)  :=q'[&p_name]';
   p_attr           varchar2(15)  :=q'[&p_attr]';
   p_value          varchar2(500) :=q'[&p_value]';
   
begin
   dbms_sqldiag.alter_sql_patch(
      name           => p_name,
      attribute_name => p_attr,
      value          => p_value
   );
   dbms_output.put_line('SQL Patch was altered.');
end;
/
