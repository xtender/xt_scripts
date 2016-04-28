with a as (select dbms_qopatch.get_opatch_lsinventory patch_output from dual)
select x.*
  from a,
       xmltable('InventoryInstance/patches/*'
          passing a.patch_output
          columns
             patch_id number path 'patchID',
             patch_uid number path 'uniquePatchID',
             description varchar2(80) path 'patchDescription',
             applied_date varchar2(30) path 'appliedDate',
             sql_patch varchar2(8) path 'sqlPatch',
             rollbackable varchar2(8) path 'rollbackable'
       ) x;