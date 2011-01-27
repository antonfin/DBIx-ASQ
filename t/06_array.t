#
#===============================================================================
#
#  DESCRIPTION:  fetch data from DB (array)
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
    my $_row_arr  = $sth->fetchrow_arrayref();
    
    # TESTING

    # test array 1
    my $row_arr = $db->select( @{$query->[1]} )->array;
    ok ( $row_arr,                          $i . ' Must be exists'      );
    is ( ref $row_arr, 'ARRAY',             $i . ' Must be array ref'   );
    ok ( eq_array( $row_arr, $_row_arr ),   $i . ' Must be equal 1'     );

    # test array 2
    my @row_arr = $db->select( @{$query->[1]} )->array;
    ok ( scalar @row_arr,                   $i . ' Must be not empty'   );
    ok ( eq_array( \@row_arr, $_row_arr ),  $i . ' Must be equal 2'     );

    # array 1 == array 2
    ok ( eq_array( \@row_arr, $row_arr ),   $i . ' Must be equal 3'     );
}

# delete sqlite db
$_dbh->drop();

1;

