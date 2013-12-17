col owner format a30
col oname format a30 heading "Object name"
col cname format a30 heading "Column name"
accept owner_mask prompt "Enter owner mask: ";
accept tab_name prompt "Enter tab_name mask: ";
accept col_name prompt "Enter col_name mask: ";

SELECT a.username              as owner
      ,o.name                  as oname
      ,c.name                  as cname
      ,u.equality_preds        as equality_preds
      ,u.equijoin_preds        as equijoin_preds
      ,u.nonequijoin_preds     as nonequijoin_preds
      ,u.range_preds           as range_preds
      ,u.like_preds            as like_preds
      ,u.null_preds            as null_preds
      ,to_char(u.timestamp, 'yyyy-mm-dd hh24:mi:ss') when
FROM   
       sys.col_usage$ u
     , sys.obj$       o
     , sys.col$       c
     , all_users      a
WHERE  a.user_id = o.owner#
AND    u.obj#    = o.obj#
AND    u.obj#    = c.obj#
AND    u.intcol# = c.col#
AND    a.username like upper('&owner_mask')
AND    o.name     like upper('&tab_name')
AND    c.name     like upper('&col_name')
ORDER  BY a.username, o.name, c.name
;
col owner clear;
col oname clear;
col cname clear;
undef tab_name col_name owner_mask;