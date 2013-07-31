accept obj_name -
       prompt 'Enter object name: ' -
       default 'X0X0X0X0'
	   
select 'PSB',owner,object_type,status from dba_objects p where p.OBJECT_NAME='&&obj_name'
union all
select 'PSBF',owner,object_type,status from dba_objects@psbf p where p.OBJECT_NAME='&&obj_name'
union all
select 'PSBE',owner,object_type,status from dba_objects@psbe p where p.OBJECT_NAME='&&obj_name'
union all
select 'PSBFCT',owner,object_type,status from dba_objects@psbfct p where p.OBJECT_NAME='&&obj_name'
union all
select 'CYP1',owner,object_type,status from dba_objects@cyp1 p where p.OBJECT_NAME='&&obj_name'
order by 1,2,3
/
