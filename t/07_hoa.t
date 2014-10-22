#!/usr/bin/perl -w

# Tests for Algorithm::Dependency::HoA
# Pretty much just copied from the 03_basics.t tests

use strict;
use lib ();
use UNIVERSAL 'isa';
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		chdir ($FindBin::Bin = $FindBin::Bin); # Avoid a warning
		lib->import( catdir( updir(), updir(), 'modules') );
	}
}

use Test::More tests => 108;
use Algorithm::Dependency              ();
use Algorithm::Dependency::Source::HoA ();

my $data = {
	A => [],
	B => [ 'C' ],
	C => [],
	D => [ 'E', 'F' ],
	E => [],
	F => [],
	};

# Load the data/basics.txt file in as a source file, and test it rigorously.
my $Source = Algorithm::Dependency::Source::HoA->new( $data );

ok( $Source, "Source is true" );
ok( ref $Source, "Source is a reference" );
isa_ok( $Source, 'Algorithm::Dependency::Source::HoA' );
isa_ok( $Source, 'Algorithm::Dependency::Source' );
ok( exists $Source->{loaded}, "Source has a loaded value" );
ok( ! $Source->{loaded}, "Source isn't loaded" );

ok( eval {$Source->load;}, "Source ->load returns true" );
ok( $Source->{loaded}, "Source appears to be loaded" );
ok( isa( $Source->item('A'), 'Algorithm::Dependency::Item' ), "->item returns an Item for A" );
ok( isa( $Source->item('B'), 'Algorithm::Dependency::Item' ), "->item returns an Item for B" );
ok( isa( $Source->item('D'), 'Algorithm::Dependency::Item' ), "->item returns an Item for D" );
ok( ! defined $Source->item('BAD'), "->item for bad value properly returns undef" );

ok( $Source->item('A')->id eq 'A', "Item ->id appears to work ok" );
ok( scalar $Source->item('A')->depends == 0, "Item ->depends for 0 depends returns ok" );
ok( scalar $Source->item('B')->depends == 1, "Item ->depends for 1 depends returns ok" );
ok( scalar $Source->item('D')->depends == 2, "Item ->depends for 2 depends returns ok" );

my @items = $Source->items;
ok( scalar @items == 6, "Source ->items returns a list" );
ok( isa( $items[0], 'Algorithm::Dependency::Item' ), "List contains Items" );
ok( isa( $items[1], 'Algorithm::Dependency::Item' ), "List contains Items" );
ok( isa( $items[3], 'Algorithm::Dependency::Item' ), "List contains Items" );





# Try to create a basic unordered dependency
my $Dep = Algorithm::Dependency->new( source => $Source );
ok( $Dep, "Algorithm::Dependency->new returns true" );
ok( ref $Dep, "Algorithm::Dependency->new returns reference" );
ok( isa( $Dep, 'Algorithm::Dependency'), "Algorithm::Dependency->new returns correctly" );
ok( $Dep->source, "Dependency->source returns true" );
ok( $Dep->source eq $Source, "Dependency->source returns the original source" );
ok( $Dep->item('A'), "Dependency->item returns true" );
ok( $Dep->item('A') eq $Source->item('A'), "Dependency->item returns the same as Source->item" );
my @tmp;
ok( scalar( @tmp = $Dep->selected_list ) == 0, "Dependency->selected_list returns empty list" );
ok( ! $Dep->selected('Foo'), "Dependency->selected returns false on bad input" );
ok( ! $Dep->selected('A'), "Dependency->selected returns false when not selected" );
ok( ! defined $Dep->depends('Foo'), "Dependency->depends fails correctly on bad input" );
foreach my $data ( [
	['A'],		[],		['A'] 			], [
	['B'],		['C'],		['B','C'] 		], [
	['C'],		[], 		['C']			], [
	['D'],		['E','F'],	[qw{D E F}]		], [
	['E'],		[],		['E']			], [
	['F'],		[],		['F']			], [
	['A','B'],	['C'],		[qw{A B C}]		], [
	['B','D'],	[qw{C E F}],	[qw{B C D E F}]		]
) {
	my $args = join( ', ', map { "'$_'" } @{ $data->[0] } );
	my $rv = $Dep->depends( @{ $data->[0] } );
	ok( $rv, "Dependency->depends($args) returns something" );
	is_deeply( $rv, $data->[1], "Dependency->depends($args) returns expected values" );
	$rv = $Dep->schedule( @{ $data->[0] } );
	ok( $rv, "Dependency->schedule($args) returns something" );
	is_deeply( $rv, $data->[2], "Dependency->schedule($args) returns expected values" );
}

# Create with one selected
$Dep = Algorithm::Dependency->new( source => $Source, selected => [ 'F' ] );
ok( $Dep, "Algorithm::Dependency->new returns true" );
ok( ref $Dep, "Algorithm::Dependency->new returns reference" );
ok( isa( $Dep, 'Algorithm::Dependency'), "Algorithm::Dependency->new returns correctly" );
ok( $Dep->source, "Dependency->source returns true" );
ok( $Dep->source eq $Source, "Dependency->source returns the original source" );
ok( $Dep->item('A'), "Dependency->item returns true" );
ok( $Dep->item('A') eq $Source->item('A'), "Dependency->item returns the same as Source->item" );
ok( scalar( @tmp = $Dep->selected_list ) == 1, "Dependency->selected_list returns empty list" );
ok( ! $Dep->selected('Foo'), "Dependency->selected returns false when wrong" );
ok( ! $Dep->selected('A'), "Dependency->selected returns false when expected" );
ok( $Dep->selected('F'), "Dependency->selected return true" );
ok( ! defined $Dep->depends('Foo'), "Dependency->depends fails correctly on bad input" );
foreach my $data ( [
	['A'],		[],		['A'] 			], [
	['B'],		['C'],		[qw{B C}] 		], [
	['C'],		[], 		['C']		], [
	['D'],		['E'],		[qw{D E}]	], [
	['E'],		[],		['E']		], [
	['F'],		[],		[]		], [
	['A','B'],	['C'],		[qw{A B C}]	], [
	['B','D'],	[qw{C E}],	[qw{B C D E}]	]
) {
	my $args = join( ', ', map { "'$_'" } @{ $data->[0] } );
	my $rv = $Dep->depends( @{ $data->[0] } );
	ok( $rv, "Dependency->depends($args) returns something" );
	is_deeply( $rv, $data->[1], "Dependency->depends($args) returns expected values" );
	$rv = $Dep->schedule( @{ $data->[0] } );
	ok( $rv, "Dependency->schedule($args) returns something" );
	is_deeply( $rv, $data->[2], "Dependency->schedule($args) returns expected values" );
}

# Does missing dependencies return defined but false for a source we
# know doesn't have any missing dependencies
is( $Source->missing_dependencies, 0, "->missing_dependencies returns as expected when nothing missing" );

1;

