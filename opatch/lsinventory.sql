col lsinventory for a300;
select xmltransform(dbms_qopatch.get_opatch_lsinventory, dbms_qopatch.get_opatch_xslt) 
  as lsinventory
from dual;
col lsinventory clear;