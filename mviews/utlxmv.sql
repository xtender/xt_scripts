CREATE TABLE MV_CAPABILITIES_TABLE
  (STATEMENT_ID         VARCHAR(128),  -- Client-supplied unique statement identifier
   MVOWNER              VARCHAR(128),  -- NULL for SELECT based EXPLAIN_MVIEW
   MVNAME               VARCHAR(128),  -- NULL for SELECT based EXPLAIN_MVIEW
   CAPABILITY_NAME      VARCHAR(128),  -- A descriptive name of the particular
                                      -- capability:
                                      -- REWRITE
                                      --   Can do at least full text match
                                      --   rewrite
                                      -- REWRITE_PARTIAL_TEXT_MATCH
                                      --   Can do at leat full and partial
                                      --   text match rewrite
                                      -- REWRITE_GENERAL
                                      --   Can do all forms of rewrite
                                      -- REFRESH
                                      --   Can do at least complete refresh
                                      -- REFRESH_FROM_LOG_AFTER_INSERT
                                      --   Can do fast refresh from an mv log
                                      --   or change capture table at least
                                      --   when update operations are
                                      --   restricted to INSERT
                                      -- REFRESH_FROM_LOG_AFTER_ANY
                                      --   can do fast refresh from an mv log
                                      --   or change capture table after any
                                      --   combination of updates
                                      -- PCT
                                      --   Can do Enhanced Update Tracking on
                                      --   the table named in the RELATED_NAME
                                      --   column.  EUT is needed for fast
                                      --   refresh after partitioned
                                      --   maintenance operations on the table
                                      --   named in the RELATED_NAME column
                                      --   and to do non-stale tolerated
                                      --   rewrite when the mv is partially
                                      --   stale with respect to the table
                                      --   named in the RELATED_NAME column.
                                      --   EUT can also sometimes enable fast
                                      --   refresh of updates to the table
                                      --   named in the RELATED_NAME column
                                      --   when fast refresh from an mv log
                                      --   or change capture table is not
                                      --   possilbe.
   POSSIBLE             CHARACTER(1), -- T = capability is possible
                                      -- F = capability is not possible
   RELATED_TEXT         VARCHAR(2000),-- Owner.table.column, alias name, etc.
                                      -- related to this message.  The
                                      -- specific meaning of this column
                                      -- depends on the MSGNO column.  See
                                      -- the documentation for
                                      -- DBMS_MVIEW.EXPLAIN_MVIEW() for details
   RELATED_NUM          NUMBER,       -- When there is a numeric value
                                      -- associated with a row, it goes here.
                                      -- The specific meaning of this column
                                      -- depends on the MSGNO column.  See
                                      -- the documentation for
                                      -- DBMS_MVIEW.EXPLAIN_MVIEW() for details
   MSGNO                INTEGER,      -- When available, QSM message #
                                      -- explaining why not possible or more
                                      -- details when enabled.
   MSGTXT               VARCHAR(2000),-- Text associated with MSGNO.
   SEQ                  NUMBER);
                                      -- Useful in ORDER BY clause when
                                      -- selecting from this table.

