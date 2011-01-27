#
#===============================================================================
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Anton Morozov (anton@antonfin.kiev.ua)
#      CREATED:  27.01.2011 16:44:27
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

plan tests => 2 + 6 * @insert;

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

    my $id = $sth->last_insert_id;
    ok( $id,            'Must be true'      );
    ok( $id =~ /^\d+$/, 'Must be integer'   );

    my $row = $db->select( $data->[0], [ keys %{$data->[1]} ], { id => $id } )->hash;
    ok( eq_hash( $row, $data->[1]), 'Check data in DB 1' );

    $row = $db->select( $data->[0], '*', $data->[1] )->hash;
    is ( $id, $row->{id}, 'Check data in DB 2' )
}

ok( $db->disconnect(), "Close DB" );

# delete sqlite db
$_dbh->drop();

1;

