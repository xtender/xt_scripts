set echo OFF SQLBLANKLINES ON

var mask varchar2(30)
exec :mask:=upper('%&1%');
set define off

with help_topics as (
select 'appinfo' topic
,'APPI[NFO] {ON|OFF|text}
   Application info for performance monitor (see DBMS_APPLICATION_INFO)
' help from dual
union all
select 'ARRAYSIZE',
'ARRAY[SIZE] {15|n}
   Fetch size (1 to 5000) the number of rows that will be retrieved in one go.
' from dual
union all
select 'Autocommit',
'AUTO[COMMIT] {OFF|ON|IMM[EDIATE]|n} 
   Autocommit commits after each SQL command or PL/SQL block
' from dual
union all
select 'autoprint',
'AUTOP[RINT] {OFF|ON}
   Automatic PRINTing of bind variables.(see PRINT)
' from dual
union all
select 'AUTORECOVERY',
'AUTORECOVERY [ON|OFF]
   Configure the RECOVER command to automatically apply 
   archived redo log files during recovery - without any user confirmation.
' from dual
union all
select 'autotrace',
'AUTOT[RACE] {OFF|ON|TRACE[ONLY]} [EXP[LAIN]] [STAT[ISTICS]] 
   Display a trace report for SELECT, INSERT, UPDATE or DELETE statements
   EXPLAIN shows the query execution path by performing an EXPLAIN PLAN.
   STATISTICS displays SQL statement statistics.
   Using ON or TRACEONLY with no explicit options defaults to EXPLAIN STATISTICS
' from dual
union all
select 'BLOCKTERMINATOR',
'BLO[CKTERMINATOR] {.|c|OFF|ON}
   Set the non-alphanumeric character used to end PL/SQL blocks to c
' from dual
union all
select 'CMDSEP',
'CMDS[EP] {;|c|OFF|ON}
   Change or enable command separator - default is a semicolon (;)
' from dual
union all
select 'COLSEP',
'COLSEP { |text} 
   The text to be printed between SELECTed columns normally a space.
' from dual
union all
select 'COMPATIBILITY',
'COM[PATIBILITY] {V5|V6|V7|V8|NATIVE}
   Version of oracle - see also init.ora COMPATIBILITY=
   You can set this back by up to 2 major versions e.g. Ora 9 supports 8 and 7
' from dual
union all
select 'CONCAT',
'CON[CAT] {.|c|OFF|ON}
   termination character for substitution variable reference
   default is a period.
' from dual
union all
select 'COPYCOMMIT',
'COPYC[OMMIT] {0|n}
   The COPY command will fetch n batches of data between commits.
   (n= 0 to 5000) the size of each fetch=ARRAYSIZE.
   If COPYCOMMIT = 0, COPY will commit just once - at the end.
' from dual
union all
select 'COPYTYPECHECK',
'COPYTYPECHECK {OFF|ON}
   Suppres the comparison of datatypes while inserting or appending to DB2
' from dual
union all
select 'DEFINE',
'DEF[INE] {&|c|OFF|ON}
   c =  the char used to prefix substitution variables. 
   ON or OFF controls whether to replace substitution variables with their values.
   (this overrides SET SCAN) 
' from dual
union all
select 'DESCRIBE',
'DESCRIBE [DEPTH {1|n|ALL}][LINENUM {ON|OFF}][INDENT {ON|OFF}]
   Sets the depth of the level to which you can recursively describe an object
   (1 to 50) see the DESCRIBE command 
' from dual
union all
select 'ECHO',
'ECHO {OFF|ON}
   Display commands as they are executed
' from dual
union all
select 'EMBEDDED',
'EMB[EDDED] {OFF|ON}
   OFF = report printing will start at the top of a new page.
   ON = report printing may begin anywhere on a page.
' from dual
union all
select 'ESCAPE',
'ESC[APE] {\|c|OFF|ON} 
    Defines the escape character. OFF undefines. ON enables. 
' from dual
union all
select 'FEEDBACK',
'FEED[BACK] {6|n|OFF|ON}
   Display the number of records returned (when rows >= n )
   OFF (or n=0) will turn the display off
   ON will set n=1
' from dual
union all
select 'FLAGGER',
'FLAGGER {OFF|ENTRY|INTERMED[IATE]|FULL}
   Checks to make sure that SQL statements conform to the ANSI/ISO SQL92 standard.
   non-standard constructs are flagged as errors and displayed 
   See also ALTER SESSION SET FLAGGER.
' from dual
union all
select 'FLUSH',
'FLU[SH] {OFF|ON}
   Buffer display output (OS)
   (no longer used in Oracle 9)
' from dual
union all
select 'HEADING',
'HEA[DING] {OFF|ON}
   print column headings
' from dual
union all
select 'HEADSEP',
'HEADS[EP] {||c|OFF|ON}
   Define the heading separator character (used to divide a column heading onto > one line.)
   OFF will actually print the heading separator char
   see also: COLUMN command
' from dual
union all
select 'INSTANCE',
'INSTANCE [instance_path|LOCAL] 
   Change the default instance for your session, this command may only be issued when 
   not already connected and requires Net8
' from dual
union all
select 'LINESIZE',
'LIN[ESIZE] {150|n} 
   Width of a line (before wrapping to the next line)
   Earlier versions default to 80, Oracle 9 is 150
' from dual
union all
select 'LOBOFFSET',
'LOBOF[FSET] {n|1}
   Starting position from which CLOB and NCLOB data is retrieved and displayed
' from dual
union all
select 'LOGSOURCE',
'LOGSOURCE [pathname] 
   Change the location from which archive logs are retrieved during recovery
   normally taken from LOG_ARCHIVE_DEST 
' from dual
union all
select 'LONG',
'LONG {80|n}
   Set the maximum width (in chars) for displaying and copying LONG values.
' from dual
union all
select 'LONGCHUNKSIZE',
'LONGC[HUNKSIZE] {80|n}
   Set the fetch size (in chars) for retrieving LONG values.
' from dual
union all
select 'MARKUP HTML',
'MARK[UP] HTML [ON|OFF]
  [HEAD text] [BODY text] [TABLE text] 
     [ENTMAP {ON|OFF}][SPOOL {ON|OFF}]
        [PRE[FORMAT] {ON|OFF}]
   Output HTML text, which is the output used by iSQL*Plus.
' from dual
union all
select 'NEWPAGE',
'NEWP[AGE] {1|n}
   The number of blank lines between the top of each page and the top title.
   0 = a formfeed between pages.
' from dual
union all
select 'NULL',
'NULL text
   Replace a null value with ''text''
   The NULL clause of the COLUMN command will override this for a given column.
' from dual
union all
select 'NUMFORMAT',
'NUMF[ORMAT] format
   The default number format.
   see COLUMN FORMAT. 
' from dual
union all
select 'NUMWIDTH',
'NUM[WIDTH] {10|n}
   The default width for displaying numbers.
' from dual
union all
select 'PAGESIZE',
'PAGES[IZE] {14|n}
   The height of the page - number of lines.
   0 will suppress all headings, page breaks, titles
' from dual
union all
select 'PAUSE',
'PAU[SE] {OFF|ON|text}
   press [Return] after each page
   enclose ''text'' in single quotes
' from dual
union all
select 'RECSEP',
'RECSEP {WR[APPED]|EA[CH]|OFF}
   Print a single line of the RECSEPCHAR between each record.
   WRAPPED = print only for wrapped lines
   EACH=print for every row
' from dual
union all
select 'RECSEPCHAR',
'RECSEPCHAR {_|c}
   Define the RECSEPCHAR character, default= '' ''
' from dual
union all
select 'SCAN',
'SCAN {OFF|ON}
   OFF = disable substitution variables and parameters
' from dual
union all
select 'SERVEROUTPUT',
'SERVEROUT[PUT] {OFF|ON} [SIZE n] [FOR[MAT] {WRA[PPED]|WOR[D_WRAPPED]|TRU[NCATED]}] 
   whether to display the output of stored procedures (or PL/SQL blocks)
   i.e., DBMS_OUTPUT.PUT_LINE

   SIZE = buffer size (2000-1,000,000) bytes
' from dual
union all
select 'SHOWMODE',
'SHOW[MODE] {OFF|ON}
   Display old and new settings of a system variable
' from dual
union all
select 'SPACE',
'SPA[CE] {1|n}
   The number of spaces between columns in output (1-10)
' from dual
union all
select 'SQLBLANKLINES',
'SQLBL[ANKLINES] {ON|OFF} 
   Allow blank lines within an SQL command. reverts to OFF after the curent command/block.
' from dual
union all
select 'SQLCASE',
'SQLC[ASE] {MIX[ED]|LO[WER]|UP[PER]} 
   Convert the case of SQL commands and PL/SQL blocks
   (but not the SQL buffer itself)
' from dual
union all
select 'SQLPLUSCOMPATIBILITY',
'SQLPLUSCOMPAT[IBILITY] {x.y[.z]}
  Set the behavior or output format of VARIABLE to that of the
  release or version specified by x.y[.z]. 
' from dual
union all
select 'SQLCONTINUE',
'SQLCO[NTINUE] {> |text}
   Continuation prompt (used when a command is continued on an additional line using a hyphen -)
' from dual
union all
select 'SQLNUMBER',
'SQLN[UMBER] {OFF|ON}
   Set the prompt for the second and subsequent lines of a command or PL/SQL block.
   ON = set the SQL prompt = the line number.
   OFF = set the SQL prompt = SQLPROMPT.
' from dual
union all
select 'SQLPREFIX',
'SQLPRE[FIX] {#|c}
   set a non-alphanumeric prefix char for immediately executing one line of SQL (#)
' from dual
union all
select 'SQLPROMPT',
'SQLP[ROMPT] {SQL>|text}
   Set the command prompt.
' from dual
union all
select 'SQLTERMINATOR',
'SQLT[ERMINATOR] {;|c|OFF|ON}| 
   Set the char used to end and execute SQL commands to c. 
   OFF disables the command terminator - use an empty line instead.
   ON resets the terminator to the default semicolon (;).
' from dual
union all
select 'SUFFIX',
'SUF[FIX] {SQL|text} 
   Default file extension for SQL scripts
' from dual
union all
select 'TAB',
'TAB {OFF|ON}
   Format white space in terminal output.  
   OFF = use spaces to format white space.
   ON = use the TAB char.
   Note this does not apply to spooled output files.
   The default is system-dependent. Enter SHOW TAB to see the default value. 
' from dual
union all
select 'TERMOUT',
'TERM[OUT] {OFF|ON}
   OFF suppresses the display of output from a command file
   ON displays the output.
   TERMOUT OFF does not affect the output from commands entered interactively. 
' from dual
union all
select 'TIME',
'TI[ME] {OFF|ON}
   Display the time at the command prompt.
' from dual
union all
select 'TIMING',
'TIMI[NG] {OFF|ON}
   ON = display timing statistics for each SQL command or PL/SQL block run.
   OFF = suppress timing statistics
' from dual
union all
select 'TRIMOUT',
'TRIM[OUT] {OFF|ON}
   Display trailing blanks at the end of each line.
   ON = remove blanks, improving performance
   OFF = display blanks. 
   This does not affect spooled output.
   SQL*Plus ignores TRIMOUT ON unless you set TAB ON.
' from dual
union all
select 'TRIMSPOOL',
'TRIMS[POOL] {ON|OFF}
   Allows trailing blanks at the end of each spooled line.
   This does not affect terminal output.
' from dual
union all
select 'UNDERLINE',
'UND[ERLINE] {-|c|ON|OFF}
   Set the char used to underline column headings to c.
' from dual
union all
select 'VERIFY',
'VER[IFY] {OFF|ON}
   ON = list the text of a command before and after replacing substitution variables with values.
   OFF = dont display the command.
' from dual
union all
select 'WRAP',
'WRA[P] {OFF|ON}
   Controls whether to truncate or wrap the display of long lines. 
   OFF = truncate 
   ON = wrap to the next line
   The COLUMN command (WRAPPED and TRUNCATED clause) can override this for specific columns. 
' from dual
)
select help
from help_topics
where upper(topic) like :mask;

undef mask;
undef &1;
set define on;