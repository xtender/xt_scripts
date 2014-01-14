#!/bin/perl

## Returns bind values from oracle trace file by specified SQL_ID

use strict;
use warnings;
use XML::LibXML;

use constant DEBUG => 0;

sub out_xml{
    my $data = shift;
    my $doc = XML::LibXML::Document->new('1.0', 'utf-8');
    my $root = $doc->createElement("SQL");
    $root->setAttribute('sql_id'     => $data->{sql_id});
    $root->setAttribute('trace_file' => $data->{trace_file});
    
    my $xbindsets = $doc->createElement('bindsets');
    
    for my $bindset ( @{ $data->{binds} } ) {
        my $xbindset = $doc->createElement('bindset');
        
        for my $bind (sort keys %{$bindset->{values}}) {
            my $xbind = $doc->createElement('bind');
            $xbind->setAttribute('name'=>$bind);
            
            my $xvalue = $doc->createElement('value');
            $xvalue->appendTextNode($bindset->{values}->{$bind}->{value});
            my $xdtype = $doc->createElement('datatype');
            $xdtype->appendTextNode($bindset->{values}->{$bind}->{datatype});
            
            $xbind->appendChild($xvalue);
            $xbind->appendChild($xdtype);
            
            $xbindset->appendChild($xbind);
        }
        $xbindsets->appendChild($xbindset);
    }
    
    $root->appendChild($xbindsets);
    $doc->setDocumentElement($root);
    print $doc->toString(2);
    }

sub out_json_simple{
    my $data=shift;
    my $c=0;
    print "binds:[\n";
    for my $bind ( @{ $data->{binds} } ) {
        print $c++?",":" ";
        print "{"
              ,join(
                    ","
                   , map {
                       sprintf('"%s":{"value":"%s","datatype"="%s"}'
                             , $_
                             , $bind->{values}->{$_}->{value}
                             , $bind->{values}->{$_}->{datatype}
                             )
                    } sort keys %{$bind->{values}}
              ),"}\n";
    }
    print "]"
}

sub output{
    my $p = shift;
    my $format = shift || 'json';
    my %outproc = (
            'xml'   => \&out_xml
        ,   'json'  => \&out_json_simple
        );
    &{$outproc{lc $format}}($p);
}

sub debug{
    print @_ if DEBUG
    }

sub parse{

    my($fname,$sqlid) = @_;
    my $res;
    $res->{trace_file}  = $fname;
    $res->{sql_id}      = $sqlid;
    
    debug "FNAME  = $fname\n";
    debug "SQL_ID = $sqlid\n";
    
    my %cursors;
    my $cur;
    my $n=-1;
    my $bind_num;
    my $dty;
    # get all cursors:
    open(FIN, "<", $fname) || die "@!";
    L0:
    while (<FIN>){
        my $current = $_;
        
        if(/PARSING IN CURSOR #(\d+) .* sqlid='([^']+)'/){
            $cursors{$1}=$2;
            #debug($_);
            next L0;
        }
        #elsif(/CLOSE #(\d+):/){
        #    delete $cursors{$1};
        #    next L0;
        #}
        elsif(/BINDS #(\d+):/){
            $cur = $1;
            if($cursors{$cur} eq $sqlid) {
                $n++;
                $res->{binds}[$n]->{cur}=$cur;
                #debug "\ncursor = $cur";
                debug("\n");
                BINDS:
                while(1){
                    $b=<FIN>;
                    if($b!~/^ .*/){
                        last BINDS;
                    }elsif($b=~/^ (Bind#\d+)/){
                        $bind_num=$1;
                        debug "\t$1"
                    }elsif($b=~/^  oacdty=(\d+)/){
                        $dty=$1;
                    }elsif($b=~/^  value=(.*)$/){
                        $res->{binds}[$n]->{values}->{$bind_num}->{value} = $1;
                        $res->{binds}[$n]->{values}->{$bind_num}->{datatype} = $dty;
                        debug "=$1"
                    }
                }
            }
        }
    }
    close FIN;
    return $res
}


# main:
my ($p_tracefile,$p_sqlid,$p_format) = @ARGV;
if (!$p_tracefile) {die("\nUsage:\n get_binds_from_trace_by_sqlid.pl trace_file sqlid [format]\nFormat can be [xml,json]\n")}

my $res = parse($p_tracefile,$p_sqlid);
output($res, $p_format)