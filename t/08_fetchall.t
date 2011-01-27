#
#===============================================================================
#
#  DESCRIPTION:  fetch data from DB (fetchall)
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

plan tests => 1 + 4 * @TestQuery::sql_and_params;

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

    # fetch list like array ref of arrays: fetchall_arrayref analog
    my $sth = $_dbh->prepare( $query->[0] );

    $sth->execute;
    my $_list_arr_hash = [];
    while( my $r = $sth->fetchrow_hashref ) {
        push @$_list_arr_hash, $r;
    }
    
    #   TESTING

    # test fetchall_arrayref
    my $list_arr_hash = $db->select( @{$query->[1]} )->fetchall;
    ok ( $list_arr_hash,                            $i . ' Must be exists'          );
    is ( ref $list_arr_hash, 'ARRAY',               $i . ' Must be array ref'       );
    is ( ref $list_arr_hash->[0], 'HASH',           $i . ' Elements must be hash'   );
    ok ( eq_array( $list_arr_hash, $_list_arr_hash ),$i . ' Must be equal'           );
}

# delete sqlite db
$_dbh->drop();

1;

