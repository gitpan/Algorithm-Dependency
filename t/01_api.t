#!/usr/bin/perl -w

# Basic load and method existance tests for Algorithm::Dependency

BEGIN { $| = 1; }
use strict;
use lib '../../modules'; # For development testing
use lib '../lib'; # For installation testing
use UNIVERSAL 'can';
use Test::More tests => 32;




# Check their perl version
BEGIN {
	ok( $] >= 5.005, "Your perl is new enough" );
}



# Set up the test structure
use vars qw{$methods};
BEGIN {
	$methods = {
		'Algorithm::Dependency' => [qw{
			new source selected selected_list
			item depends schedule
			}],
		'Algorithm::Dependency::Ordered' => [qw{
			new source selected selected_list
			item depends schedule
			}],
		'Algorithm::Dependency::Item' => [qw{
			new id depends
			}],
		'Algorithm::Dependency::Source' => [qw{
			new load item items
			}],
		'Algorithm::Dependency::Source::File' => [qw{
			new load item items _load_item_list
			}],
		};

}

# Try to load the modules
foreach my $class ( sort keys %$methods ) {
	# Try to load the class
	ok( (eval("use $class; 1;") ? 1 : 0), "$class loads" );
}

# Now test their methods exist
foreach my $class ( sort keys %$methods ) {
	foreach my $method ( @{ $methods->{$class} } ) {
		ok( can( $class, $method ), "Class '$class' has method '$method'" );
	}
}
