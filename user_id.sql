prompt &_S_REVERSE *** Find user from dba_users by user_id(number) *** &_C_RESET
col username                format a30;
col account_status          format a15;
col external_name           format a15;
col profile                 format a12;

col default_tablespace          noprint;
col temporary_tablespace        noprint;
col initial_rsrc_consumer_group noprint;
col password                    noprint
col lock_date                   noprint;
col expiry_date                 noprint;
col editions_enabled            noprint;
select * from dba_users where user_id =&1;
col username                    clear;
col password                    clear;
col account_status              clear;
col default_tablespace          clear;
col temporary_tablespace        clear;
col external_name               clear;
col profile                     clear;
col initial_rsrc_consumer_group clear;
col lock_date                   clear;
col expiry_date                 clear;