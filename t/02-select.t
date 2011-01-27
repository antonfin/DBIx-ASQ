#
#===============================================================================
#
#  DESCRIPTION:  select data from DB
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Anton Morozov (anton@antonfin.kiev.ua)
#      CREATED:  17.09.2010 09:17:06
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;
use DBIx::ASQ;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use TestDB;

# create sqlite db for test
my $_dbh = TestDB->new_db( 'sqlite' );

$_dbh->disconnect();

my $sqlite_db = $_dbh->file;

# TESTING

my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );

# test select method
my $sth = $db->select( 'books' );

ok ( $sth, 'sth object exists' );
is ( ref $sth, 'DBIx::ASQ::sth', 'sth is object' );

# finish        - TODO without finish!!!
$sth->finish;

$db->disconnect();

# delete sqlite db
$_dbh->drop();

1;

