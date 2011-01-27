#
#===============================================================================
#
#  DESCRIPTION:  check insert function
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

use Test::More;
use DBIx::ASQ;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use TestDB;
use TestQuery;

my @insert = @TestQuery::INSERT;

plan tests => 2 + 3 * @insert;

# create sqlite db for test
#   and close connect
my $_dbh = TestDB->create( 'sqlite' )->disconnect;

my $sqlite_db = $_dbh->file;

# delete sqlite file before finish
$SIG{__DIE__} = sub{ $_dbh->drop; warn $_[0]; exit; };


# start test
my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db", "", "" );

ok ( $db, 'DB object exists' );

foreach my $data ( @insert ) {
    my $sth = $db->insert( $data->[0], $data->[1] );
    ok( $sth,       'Must be true'  );
    ok( ref $sth,   'Must be object');

    my $row = $db->select( $data->[0], [ keys %{$data->[1]} ], $data->[1] )->hash;
    ok( eq_hash( $row, $data->[1]), "Check data in the DB 1" );
}

ok( $db->disconnect(), "Close DB" );

# delete sqlite db
$_dbh->drop();

1;

