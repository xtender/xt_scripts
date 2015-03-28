host echo "set linesize" $(stty -a | perl -nE 'say $1 if m!columns (\d+)!') > &_TEMPDIR./linesize.sql 
@&_TEMPDIR./linesize.sql 
host rm -f &_TEMPDIR./linesize.sql 
