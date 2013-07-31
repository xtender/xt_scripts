@inc/input_vars_init.sql;
@tpt/snapper ash1,stats,gather=sw,sinclude=read|direct|cache &1 &2 &3
@inc/input_vars_undef.sql;