#!/usr/bin/perl -w

# Creating and using dependency trees

BEGIN { $| = 1; }
use strict;
use lib '../../modules'; # For development testing
use lib '../lib'; # For installation testing
use UNIVERSAL 'isa';
use Test::More tests => 110;
use File::Spec;
use Algorithm::Dependency;
use Algorithm::Dependency::Source::File;





# Load the data/basics.txt file in as a source file, and test it rigorously.
my $file = File::Spec->catfile( 'data', 'basics.txt' );
my $Source = Algorithm::Dependency::Source::File->new( $file );

ok( $Source, "Source is true" );
ok( ref $Source, "Source is a reference" );
ok( isa( $Source, 'Algorithm::Dependency::Source::File' ), "Source is a Source::File" );
ok( isa( $Source, 'Algorithm::Dependency::Source' ), "Source is a Source" );
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
ok( ($items[0]->id eq 'A' and $items[1]->id eq 'B' and $items[3]->id eq 'D'), "Source ->items returns in original database order" );
ok( $items[0] eq $Source->item('A'), "Hash and list refer to the same object" );





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

# Try a bad creation
ok( ! defined Algorithm::Dependency->new(), "Dependency->new fails correctly" );

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

1;

