col lsinventory for a300;
spool &_spools./lsinventory.txt
select xmltransform(dbms_qopatch.get_opatch_lsinventory, dbms_qopatch.get_opatch_xslt) 
  as lsinventory
from dual;
spool off;
host &_START &_spools./lsinventory.txt
col lsinventory clear;