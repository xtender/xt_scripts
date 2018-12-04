@inc/input_vars_init;
col name	format a50
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
and (
	   a.ksppinm like nullif('%&1%','%%') escape '\'
	or a.ksppinm like nullif('%&2%','%%') escape '\'
	or a.ksppinm like nullif('%&3%','%%') escape '\'
	or a.ksppinm like nullif('%&4%','%%') escape '\'
	or a.ksppinm like nullif('%&5%','%%') escape '\'
	or a.ksppinm like nullif('%&6%','%%') escape '\'
	or a.ksppinm like nullif('%&7%','%%') escape '\'
	or a.ksppinm like nullif('%&8%','%%') escape '\'
	or a.ksppinm like nullif('%&9%','%%') escape '\'
)
order by name
/
col name	clear;
col value	clear;
col deflt	clear;
col type 	clear;
col description	clear;
@inc/input_vars_undef;
