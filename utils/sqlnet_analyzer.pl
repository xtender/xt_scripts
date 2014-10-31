#!/usr/bin/perl

use Time::Local;
use Term::ANSIColor qw(:constants colored);

use strict;

# my modules:
use FindBin;               # locate this script
use lib "$FindBin::Bin/";  # use the parent directory
use TreeNode;

##################################################################
#           configuration:
use constant MASK_REC   => '(\[[^]]+\]) ([_a-zA-Z]+):(.*)$';
use constant MASK_DATE  => '(\d\d):(\d\d):(\d\d):(\d{3})(?=])';
use constant EXCEPTIONS => qw(  nzddri_init nacomin nas_gusl nnflctxmap 
                                nnfgiinit nnfggav nnfgsrsp nnfgsrdp nttctl
                                nzupgew_get_environ_wrl nnfloidinfocache
                                nzumrealloc nzumalloc );
use constant MASK_EXCEPTIONS => '^('.join('|',EXCEPTIONS).')$';
my $pathlen=60;

# coloring:
use constant COLORED    => 1;
# percentile values for colors:
use constant PCT1=>70;
use constant PCT2=>95;
# colors:
use constant C_MAIN_1       => YELLOW;
use constant C_MAIN_2       => RED;
use constant C_AVG_1        => REVERSE;
use constant C_AVG_2        => REVERSE;
use constant C_TIME_1       => BOLD;
use constant C_TIME_2       => BOLD;
use constant C_TIME_MAX_1   => BOLD;
use constant C_TIME_MAX_2   => BOLD;
#           end configuration
##################################################################
my $FILENAME = $ARGV[0];
my $DELIM    = defined($ARGV[1])?$ARGV[1]:"\t";

# vars:
my %func;
my $tree = new TreeNode();

# percentile values for colors:
my $pct_1_avg     ;
my $pct_1_time    ;
my $pct_1_time_max;
my $pct_2_avg     ;
my $pct_2_time    ;
my $pct_2_time_max;


##################################################################
#
#                           subs:
#
#

sub str2time($) {
    my $time_shift = 0;

    $_[0] =~ /(\d{2})-(\S+)-(\d{4})\s(\d{2}):(\d{2}):(\d{2}):(\d{3})/ || print "can't decode date $_[0]";
    my $timestamp_s = $&;
    my ( $day, $month, $year, $hour, $min, $sec, $msec, $tzone ) = ( $1, uc $2, $3, $4, $5, $6, $7, 0 );
    my %m=(
        "JAN" => 0, "FEB" => 1, "MAR" => 2, "APR" => 3, "MAY" => 4, "JUN" => 5, "JUL" => 6, "AUG" => 7, "SEP" => 8, "OCT" => 9, "NOV" => 10, "DEC" => 11,
        "ßÍÂ" => 0, "ÔÅÂ" => 1, "ÌÀÐ" => 2, "ÀÏÐ" => 3, "ÌÀÉ" => 4, "ÈÞÍ" => 5, "ÈÞË" => 6, "ÀÂÃ" => 7, "ÑÅÍ" => 8, "ÎÊÒ" => 9, "ÍÎß" => 10, "ÄÅÊ" => 11,
    );
    my $timestamp = timelocal($sec,$min,$hour,$day,$m{$month},$year) + $time_shift * 60 * 60 + $msec/1000;
    return { 
            'timestamp_s' => sprintf('%.4d-%.2d-%.2d %.2d:%.2d:%.2d.%.3d',$year,$m{$month},$day,$hour,$min,$sec,$msec),
            'timestamp'   => $timestamp
           }
}
################################
sub each_func{
    my ($rec_dt,$rec_func,$rec_msg) = @_;
    my $path;
    
    if ($rec_msg=~/entry/) {
        if ($rec_func=~MASK_EXCEPTIONS){
            $path = $rec_func
        }else {
            $tree->add_child($rec_func);
            $path = $tree->get_path();
        }
        $func{$path}->{cnt}++;
        $func{$path}->{entries}++ ;
        $func{$path}->{start} = $rec_dt;
    }elsif($rec_msg=~/exit/){
        my $need_remove=1;
        if ($rec_func=~MASK_EXCEPTIONS){
            $path = $rec_func;
            $need_remove = 0;
        }else {
            $path = $tree->get_path();
        }
        
        $func{$path}->{cnt}++;
        $func{$path}->{exits  }++;
        my $delta;
        $delta = $rec_dt->{timestamp} - $func{$path}->{start}->{timestamp} if defined($func{$path}->{start}->{timestamp});
        #die $delta;
        $func{$path}->{time} += $delta;
        $func{$path}->{time_max} = $delta < $func{$path}->{time_max} ? $func{$path}->{time_max} : $delta;
        $func{$path}->{time_min} = $delta > $func{$path}->{time_min} ? $func{$path}->{time_min} : $delta;
        $func{$path}->{start} = $rec_dt;
        $func{$path}->{end}   = $rec_dt;
        $tree->remove_child($rec_func) if $need_remove;
    }elsif( $rec_msg=~/(\d+) bytes/ || $rec_msg=~/bytes.*=(\d+)/){
        $func{$tree->get_path()}->{bytes} += 0+$1;
    }
}
################################
sub each_string{
    my $ls = shift;
    
    if ($ls=~MASK_REC) {
        my $rec_dt   = str2time($1);
        my $rec_func = $2;
        my $rec_msg  = $3;
        each_func($rec_dt,$rec_func,$rec_msg);
        return 
            {
                dt      => $rec_dt,
                func    => $rec_func,
                msg     => $rec_msg
            }
    }
}

sub percentile {
    my ($p,$aref) = @_;
    my $percentile = int($p * $#{$aref}/100);
    return (sort @$aref)[$percentile];
}

sub analyze_data{
    my (@a_avg,@a_time,@a_time_max);
    
    for my $key (sort keys %func){
        $func{$key}->{avg} = $func{$key}->{time} / $func{$key}->{cnt};
        push @a_avg     , $func{$key}->{avg};
        push @a_time    , $func{$key}->{time};
        push @a_time_max, $func{$key}->{time_max};
    }
    $pct_1_avg      = percentile(PCT1,\@a_avg);
    $pct_1_time     = percentile(PCT1,\@a_time);
    $pct_1_time_max = percentile(PCT1,\@a_time_max);
    
    $pct_2_avg      = percentile(PCT2,\@a_avg);
    $pct_2_time     = percentile(PCT2,\@a_time);
    $pct_2_time_max = percentile(PCT2,\@a_time_max);
}

################################
sub format_path{
    # replaces by default '/aaaaaa/bbbbbb/cccccc' to /.../.../cccccc:
    my ($path, $replace) = (@_,'/...');
    $path=~s#/\w+(?=/)#$replace#g;
    return $path
    }

sub coloring{
    my ($val,$a,$b,$str,$color_a,$color_b,$color_ret) = @_;
    if ($val>=$b){
        return $color_b.$str.$color_ret
    }elsif ($val<=$a){
        return $str
    }else{
        return $color_a.$str.$color_ret
    }
}

sub print_funcs{
    analyze_data();
    printf("%-${pathlen}s \t%-8s\t %-8s\t %-8s\t %-8s\t %-8s\t %-8s\t %-8s\t %-8s\n"
                    ,'Function'
                    ,'Count'
                    ,'Time(Avg)'
                    ,'Time(All)'
                    ,'Time(Min)'
                    ,'Time(Max)'
                    ,'Bytes'
                    ,'Entries'
                    ,'Exits'
    );
    printf("%-${pathlen}s \t%-8s\t %-8s\t %-8s\t %-8s\t %-8s\t %-8s\t %-8s\t %-8s\n"
                    ,'--------'
                    ,'--------'
                    ,'--------'
                    ,'--------'
                    ,'--------'
                    ,'--------'
                    ,'--------'
                    ,'--------'
                    ,'--------'
    );
    my $s_path     = "%-${pathlen}s";
    my $s_cnt      = '%8d';
    my $s_avg      = '%8.3f';
    my $s_time     = '%8.3f';
    my $s_time_min = '%8.3f';
    my $s_time_max = '%8.3f';
    my $s_bytes    = '%8d';
    my $s_entries  = '%8d';
    my $s_exits    = '%8d';
    
    #for my $key (sort{$func{$a}->{cnt}<=>$func{$b}->{cnt}}keys %func){
    for my $key (sort keys %func){
        my $f_str;
        
        if(!COLORED){
            $f_str  = "${s_path}\t${s_cnt}\t${s_avg}\t${s_time}\t${s_time_min}\t${s_time_max}\t${s_bytes}\t${s_entries}\t${s_exits}\n";
        }else{
            
            my $b_main      = $func{$key}->{avg} >= $pct_2_avg?C_MAIN_2:
                                $func{$key}->{avg} <= $pct_1_avg?RESET:C_MAIN_1;
            my $b_avg      = coloring( $func{$key}->{avg     }, $pct_1_avg     , $pct_2_avg     , $s_avg     , C_AVG_1     , C_AVG_2      , RESET.$b_main);
            my $b_time     = coloring( $func{$key}->{time    }, $pct_1_time    , $pct_2_time    , $s_time    , C_TIME_1    , C_TIME_2     , RESET.$b_main);
            my $b_time_max = coloring( $func{$key}->{time_max}, $pct_1_time_max, $pct_2_time_max, $s_time_max, C_TIME_MAX_1, C_TIME_MAX_2 , RESET.$b_main);
            
            $f_str  = "$b_main${s_path}\t${s_cnt}\t${b_avg}\t${b_time}\t${s_time_min}\t${b_time_max}\t${s_bytes}\t${s_entries}\t${s_exits}".RESET."\n";
        }
        
        printf($f_str
                    ,format_path($key,'/..')
                    ,$func{$key}->{cnt}
                    ,$func{$key}->{avg}
                    ,$func{$key}->{time}
                    ,$func{$key}->{time_min}
                    ,$func{$key}->{time_max}
                    ,$func{$key}->{bytes}
                    ,$func{$key}->{entries}
                    ,$func{$key}->{exits}
            )
            #if $func{$key}->{entries}!=$func{$key}->{exits}
            ;
        }
}
#
#
#                end subs
############################################################################

#print "TIMESTAMP${DELIM}ENDTIMESTAMP${DELIM}BYTES${DELIM}TIME\n";
open F, '<' ,$FILENAME;
my $current = 0;
my $parent  = 0;
my $opened  = 0;
while(my $s=<F>){
    
    my $rec = each_string($s);
    
}

print_funcs;