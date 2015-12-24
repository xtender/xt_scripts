alter session set events '10843 trace name context off';
alter session set events '10046 trace name context off';
alter session set tracefile_identifier=CLEANUP;
alter session set tracefile_identifier=new;