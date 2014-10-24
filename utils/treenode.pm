package TreeNode;

use strict;
use Exporter qw(import);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

sub new {
    my $class = shift;
    my $self = { _nodes => [ @_ ] };
    bless $self, $class;
    return $self;
}

sub add_child($){
    my $self = shift;
    push @{$self->{_nodes}},@_;
}

sub get_path{
    my $self = shift;
    return '/'.join('/',@{$self->{_nodes}});
}

sub get_child{
    my $self = shift;
    return ${$self->{_nodes}}[$#{$self->{_nodes}}]
}

sub remove_child{
    my $self = shift;
    pop @{$self->{_nodes}}
}

1;