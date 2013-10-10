col name format a70;
col mbytes format 99999999.0;
select rpad(name,70,'.') name,round(bytes/1024/1024,1) mbytes,resizeable from v$sgainfo;
col name clear;