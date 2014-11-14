col name	format a40
col value	format a12
col deflt	format a12
col type 	format a12
col description	format a60

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
and b.ksppstvl like '%&1%' escape '\'
order by name
/
