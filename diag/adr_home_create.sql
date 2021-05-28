col adr_home new_value adr_home;
select value as adr_home from v$diag_info where name='ADR Home';
create or replace directory adr_home as '&adr_home';