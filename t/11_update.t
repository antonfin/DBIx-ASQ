#
#===============================================================================
#
#  DESCRIPTION:  check update function
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

my $count = 0;
$count += @{$_->[2]} for @insert;

plan tests => 2 + 2 * @insert + 2 * $count;

# create sqlite db for test
my $_dbh = TestDB->create( 'sqlite' )->disconnect;

my $sqlite_db = $_dbh->file;

$SIG{__DIE__} = sub{ $_dbh->drop; warn $_[0]; exit; };

# start test
my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );

ok ( $db, 'DB object exists' );

foreach my $data ( @insert ) {
    my $sth = $db->insert( $data->[0], $data->[1] );
    my $id = $sth->last_insert_id();
    ok( $id =~ /^\d+$/, 'Must be true and integer' );
    my $row = $db->select( $data->[0], [ keys %{$data->[1]} ], { id => $id } )->hash;
    ok( eq_hash( $row, $data->[1]), "Check data in the DB 2" );

    #   Update and check result!
    foreach my $data_update ( @{$data->[2]} ) {
        my $is_ok = $db->update( $data->[0], $data_update, { id => $id } );
        ok( $is_ok, 'Update was OK!' );
 
        my $fetch_after_update = $db->select( 
            $data->[0], [ keys %{ $data_update } ], { id => $id }
        )->hash;
        ok( eq_hash( $fetch_after_update, $data_update ), 'Check data in the DB after update' );
    }

}

ok( $db->disconnect(), "Close DB" );

# delete sqlite db
$_dbh->drop();

1;

