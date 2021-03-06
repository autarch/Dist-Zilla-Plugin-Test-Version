use strict;
use warnings;
use Test::More;
use Test::DZil;
use Test::Script 1.05;
use Test::NoTabs ();
use Test::EOL    ();
use File::chdir;
use Path::Class qw( file );

plan skip_all => 'test requires Test::Version 2.00'
  unless eval qq{ use Test::Version 2.00; 1 };

my $tzil = Builder->from_config(
  {
    dist_root    => 'corpus/a',
  },
  {
    add_files => {
      'source/dist.ini' => simple_ini(
        {},
        ['GatherDir'],
        ['Test::Version' => {
          filename_match => [ 'sub { $_[0] !~ /ConfigData/ }', 'sub { 0 }' ],
        }]
      ),
      'source/lib/Foo.pm' => "package Foo;\nour \$VERSION = 1.00;\n1;\n",
      'source/lib/Foo/ConfigData.pm' => "package Foo::ConfigData;\n1;\n",
    }
  },
);

$tzil->build;

is $tzil->prereqs->as_string_hash->{develop}->{requires}->{'Test::Version'}, '2.00', 'needs Test::Version 2.00';

my $fn = $tzil
  ->tempdir
  ->subdir('build')
  ->subdir('xt')
  ->subdir('author')
  ->file('test-version.t')
  ;

ok ( -e $fn, 'test file exists');

note $fn->slurp;

do {
  local $CWD = $tzil->tempdir->subdir('build')->stringify;
  #note "CWD = $CWD";
  Test::NoTabs::notabs_ok      ( file(qw( xt author test-version.t ))->stringify, 'test has no tabs');
  Test::EOL::eol_unix_ok       ( file(qw( xt author test-version.t ))->stringify, 'test has good EOL',   { trailing_whitespace => 1 });
  script_compiles( file(qw( xt author test-version.t ))->stringify, 'check test compiles' );
  script_runs    ( file(qw( xt author test-version.t ))->stringify, 'check test runs'     );
};

done_testing;
