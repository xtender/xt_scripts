use SQL::Beautify;
use strict;

open (SQL, "<", $ARGV[0]) || die ('File not found!');
my $query = join("\n",<SQL>);


my $beautifier = SQL::Beautify->new;
$beautifier -> add_keywords(qw{
    pivot unpivot 
    model dimension measures rules 
    xmltable xmlsequence columns});


$beautifier->query(
            $query, 
            spaces => 4, 
            space => ' ', 
            break => "\n", 
            wrap => {'$','$'}
            );

my $nice_sql = $beautifier->beautify;

print $nice_sql ."\n";