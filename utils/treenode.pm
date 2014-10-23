package TreeNode;

use strict;
use Exporter qw(import);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

sub new
{
	my $class = shift;
	

	my $self = { };
	bless $self;
	$self->{nodes} = [@_];
	return $self;
}

sub add_child($){
	my $self = shift;
	bless $self;
	push @{$self->{nodes}},@_;
}

sub get_path{
	my $self = shift;
	return '/'.join('/',@{$self->{nodes}});
	}

sub get_child{
	my $self = shift;
	return ${$self->{nodes}}[$#{$self->{nodes}}]
	}

sub remove_child{
	my $self = shift;
	pop @{$self->{nodes}}
	}

1;