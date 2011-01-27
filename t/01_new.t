#
#===============================================================================
#
#  DESCRIPTION:  open and close DB
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
# close connection
$_dbh->disconnect();

my $sqlite_db = $_dbh->file;

my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );

ok ( $db, 'DB object exists' );
is ( ref $db, 'DBIx::ASQ', 'Db is object' );

# close db
$db->disconnect();

# delete sqlite db
$_dbh->drop();

1;

