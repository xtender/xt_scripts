@inc/input_vars_init;
col name	format a64
col value	format a12
col deflt	format a12
col type 	format a12
col description	format a120

select
	a.ksppinm name
	,b.ksppstvl value
	,b.ksppstdf deflt
	,decode
		(a.ksppity
		,1,'boolean'
		,2,'string'
		,3,'number'
		,4,'file'
		,a.ksppity) type
	,a.ksppdesc description
from
	sys.x$ksppi a
	,sys.x$ksppcv b
where
	a.indx = b.indx
and a.ksppinm like '%optimizer%' escape '\'
and lower(a.ksppdesc) like lower('%&1%') escape '\'
order by name
/
col name	clear;
col value	clear;
col deflt	clear;
col type 	clear;
col description	clear;
@inc/input_vars_undef;
