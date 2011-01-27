#
#===============================================================================
#
#  DESCRIPTION:  close DB
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

use Test::More tests => 3;
use DBIx::ASQ;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use TestDB;

# create sqlite db for test
#   and close connection
my $_dbh = TestDB->create( 'sqlite' )->disconnect();

my $sqlite_db = $_dbh->file;

my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );

# close db
ok( $db->disconnect(), 'Disconnect' );

my $res = eval {
    $db->select('books')->fetchall;
};
ok ( !$res, 'No result' );
ok ( $@, 'Must be die' );

# delete sqlite db
$_dbh->drop();

1;

