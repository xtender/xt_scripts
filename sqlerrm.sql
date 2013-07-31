col err_text format a200;
select sys.standard.sqlerrm(-abs(&1)) err_text from dual;
col err_text clear