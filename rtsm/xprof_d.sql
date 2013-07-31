--prompt Running DBMS_SQLTUNE.REPORT_SQL_DETAIL for &3 => &4....

SELECT
	DBMS_SQLTUNE.REPORT_SQL_DETAIL(   
		&3=>&4
		,report_level=>'&1'
		,type => '&2'
		--,base_path    => 'file:///S:/rtsm/base_path/'
	) as report   
FROM dual
/
