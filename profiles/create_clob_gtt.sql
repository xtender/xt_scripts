create global temporary table xt_clob_tmp(id int, c clob)
lob(c) store as securefile(
      enable storage in row
      cache
      )
/
