require 5.000;
use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Algorithm::Dependency',
	'VERSION_FROM' => 'lib/Algorithm/Dependency.pm',
	'PREREQ_PM'    => {
		# For the tests
		'Test::More'     => 0,
		'File::Spec'     => 0.82,
	},
	($] >= 5.005) ? (
		'AUTHOR'     => 'Adam Kennedy (cpan@ali.as)',
		'ABSTRACT'   => 'Implements algorithms relating to dependency trees',
	) : (),
);
