Rem
Rem $Header: rdbms/admin/utlxrw.sql /main/8 2017/05/28 22:46:13 stanaya Exp $
Rem
Rem utlxrw.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates.
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlxrw.sql - Create the output table for EXPLAIN_REWRITE
Rem
Rem    DESCRIPTION
Rem     Outputs of the EXPLAIN_REWRITE goes into the table created
Rem     by utlxrw.sql (called REWRITE_TABLE). So utlxrw must be
Rem     invoked before any EXPLAIN_REWRITE tests.
Rem
Rem    NOTES
Rem      If user specifies a different name in EXPLAIN_REWRITE, then
Rem      it should have been already created before calling EXPLAIN_REWRITE.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlxrw.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlxrw.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    desingh     10/19/05 - bug#4401918:change join_back cols lengths
Rem    mthiyaga    04/29/05 - Remove unncessary comment
Rem    mthiyaga    06/08/04 - Add rewritten_txt field
Rem    mthiyaga    10/10/02 - Add extra columns
Rem    mthiyaga    09/27/00 - Create EXPLAIN_REWRITE output table
Rem    mthiyaga    09/27/00 - Created
Rem
Rem
CREATE TABLE REWRITE_TABLE(
                  statement_id          VARCHAR2(30),  -- id for the query
                  mv_owner              VARCHAR2(128),  -- owner of the MV
                  mv_name               VARCHAR2(128),  -- name of the MV
                  sequence              INTEGER,       -- sequence no of the error msg
                  query                 VARCHAR2(4000),-- user query
                  query_block_no        INTEGER,       -- block no of the current subquery
                  rewritten_txt         VARCHAR2(4000),-- rewritten query
                  message               VARCHAR2(512), -- EXPLAIN_REWRITE error msg
                  pass                  VARCHAR2(3),   -- rewrite pass no
                  mv_in_msg             VARCHAR2(128),  -- MV in current message
                  measure_in_msg        VARCHAR2(30),  -- Measure in current message
                  join_back_tbl        VARCHAR2(4000),-- Join back table in current msg
                  join_back_col        VARCHAR2(4000),-- Join back column in current msg
                  original_cost         INTEGER,       -- Cost of original query
                  rewritten_cost        INTEGER,       -- Cost of rewritten query
                  flags                 INTEGER,       -- associated flags
                  reserved1             INTEGER,       -- currently not used
                  reserved2             VARCHAR2(10))  -- currently not used
/
