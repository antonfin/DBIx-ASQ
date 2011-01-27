require 5.8.8;

use strict;
use ExtUtils::MakeMaker;

my $dep_modules = {
    'DBI'               => '0',
    # need for tests
    'Test::More'        => '0',
    'DBD::SQLite'       => '0',
    'File::Basename'    => '0',
    'FindBin'           => '0',
};

WriteMakefile(
    NAME	    => 'DBIx::ASQ',
    VERSION_FROM=> 'ASQ.pm', # finds $VERSION
    PREREQ_PM   => { %$dep_modules },
    AUTHOR      => 'Anton Morozov <anton@antonfin.kiev.ua>',
    ABSTRACT    => 'DBI extension for abstract and simple sql queries',
    LICENSE     => 'artistic_2',
    test        => { TESTS => 't/*.t' },
    clean       => { FILES => 't/lib/test*' },
);

1;

