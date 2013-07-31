use SQL::QueryBuilder::Pretty;
use strict;
open SQL, "<", $ARGV[0] || die('File not found!');

my $pretty = SQL::QueryBuilder::Pretty->new(
    '-database'       => 'MySQL',
    '-indent_ammount' => 3,
    '-indent_char'    => ' ',
    '-new_line'       => "\r\n",
);
;
my $query = join " ",<SQL>;

#print join(" ",$query);

my $escQuery = $query;
$escQuery =~ tr/$/!/;
print $escQuery;

print "****************************\n";

my $unEscQuery = $pretty->print($escQuery);
print $unEscQuery ."\n";

print "****************************\n";
$unEscQuery =~ tr/!/$/;
print $unEscQuery ."\n";