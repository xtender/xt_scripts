@inc/input_vars_init;
col ERROR           for a10;

col ERROR_ARG1      for a80;
col ERROR_ARG2      for a10 trunc;
col ERROR_ARG3      for a10 trunc;
col ERROR_ARG4      for a10 trunc;
col ERROR_ARG5      for a10 trunc;
col ERROR_ARG6      for a10 trunc;
col ERROR_ARG7      for a10 trunc;
col ERROR_ARG8      for a10 trunc;
col COMPONENT       for a20 trunc;
col SUBCOMPONENT    for a12 trunc;

select
     INCIDENT_ID
    ,PROBLEM_ID
    ,CON_ID
    ,to_char(CREATE_TIME,'yyyy-mm-dd hh24:mi:ss') CREATE_TIME
--  ,CLOSE_TIME
--  ,STATUS
--  ,FLAGS
--  ,FLOOD_CONTROLLED
    ,SIGNALLING_COMPONENT as COMPONENT
    ,ERROR_FACILITY
     ||'-'||
     ERROR_NUMBER as ERROR
    ,ERROR_ARG1
    ,ERROR_ARG2
    ,ERROR_ARG3
    ,ERROR_ARG4
--  ,ERROR_ARG5
--  ,ERROR_ARG6
--  ,ERROR_ARG7
--  ,ERROR_ARG8
--  ,SIGNALLING_SUBCOMPONENT as SUBCOMPONENT
--  ,SUSPECT_COMPONENT
--  ,SUSPECT_SUBCOMPONENT
--  ,ECID
--  ,IMPACT
--  ,ERROR_ARG9
--  ,ERROR_ARG10
--  ,ERROR_ARG11
--  ,ERROR_ARG12
--  ,CON_UID
from v$diag_incident i
where PROBLEM_ID=&1
order by incident_id desc
fetch first to_number(nvl('&2',10) default 10 on conversion error) rows only;

col ERROR            clear;
col ERROR_ARG1       clear;
col ERROR_ARG2       clear;
col ERROR_ARG3       clear;
col ERROR_ARG4       clear;
col ERROR_ARG5       clear;
col ERROR_ARG6       clear;
col ERROR_ARG7       clear;
col ERROR_ARG8       clear;
col COMPONENT        clear;
col SUBCOMPONENT     clear;

@inc/input_vars_undef;
