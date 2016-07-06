host mkdir -p /tmp/sqlplus/tmp
host bash ./inc/term_size.sh > &_TEMPDIR./linesize.sql
@&_TEMPDIR./linesize.sql
host rm -f &_TEMPDIR./linesize.sql
