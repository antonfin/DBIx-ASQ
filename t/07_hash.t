#
#===============================================================================
#
#  DESCRIPTION:  fetch data from DB (hash)
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

plan tests => 1 + 6 * @TestQuery::sql_and_params;

# create sqlite db for test
my $_dbh = TestDB->create( 'sqlite' );

my $sqlite_db = $_dbh->file;

# delete sqlite file before finish
$SIG{__DIE__} = sub{ $_dbh->drop; warn $_[0]; exit; };


my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );
ok ( $db, 'DB object exists' );

my $i = 0;
foreach my $query ( @TestQuery::sql_and_params ) {
    $i++;

    my $sth = $_dbh->prepare( $query->[0] );
    $sth->execute;
    my $_row_hash  = $sth->fetchrow_hashref();
    
    # TESTING

    # test hash 1
    my $row_hash = $db->select( @{$query->[1]} )->hash;
    ok ( $row_hash,                         $i . ' Must be exists'      );
    is ( ref $row_hash, 'HASH',             $i . ' Must be hash ref'    );
    ok ( eq_array( $row_hash, $_row_hash ), $i . ' Must be equal 1'     );

    # test hash 2
    my %row_hash = $db->select( @{$query->[1]} )->hash;
    ok ( scalar keys %row_hash,             $i . ' Must be not empty'   );
    ok ( eq_hash( \%row_hash, $_row_hash ), $i . ' Must be equal 2'     );

    # hash 1 == hash 2
    ok ( eq_hash( \%row_hash, $row_hash ),  $i . ' Must be equal 3'     );
}

# delete sqlite db
$_dbh->drop();

1;

