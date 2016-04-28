col info for a300;
select 
   XMLSERIALIZE(
      document dbms_qopatch.get_opatch_install_info 
       as CLOB 
       INDENT SIZE = 2
    ) as info 
from dual;
col info clear;