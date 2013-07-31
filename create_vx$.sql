accept xtab - 
		prompt 'Enter value for XTAB: ' -
		default 'x$ksppcv'
create view v&xtab as select * from sys.&xtab;
grant select on v&xtab to public;
