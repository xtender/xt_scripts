create view v_$parameter_ 
as
select 
	a.ksppinm   name
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
	sys.vx$ksppi a
	,sys.vx$ksppcv b
where
	a.indx = b.indx
/
create public synonym v$parameter_ for v_$parameter_;
grant select on v$parameter_ to public;