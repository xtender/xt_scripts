alter session set tracefile_identifier=new;
--alter session set events '43905 trace name context off';
--alter session set events '10843 trace name context off';
alter session set events 'trace[Result_Cache] off';