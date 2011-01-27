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

my @sql_and_params = (
    [ 'select * from books', [ 'books' ], 'id' ],
    [ 'select * from authors', [ 'authors' ], 'id' ],
    [ 'select id from authors', [ 'authors', 'id' ], 'id' ],
    [ 'select name from authors', [ 'authors', 'name' ], 'name' ],
    [ 'select id, name from authors', [ 'authors', 'id, name' ], 'id' ],
    [ 'select id, name from authors', [ 'authors', ['id', 'name'] ], 'id' ],
    [ 'select id, name from authors', [ 'authors', ['id', undef, 'name', ''] ], 'id' ],
    [ 'select * from authors', [ 'authors', [] ], 'id' ],
    [ 'select * from authors where id = 1', [ 'authors', undef, { id => 1 } ], 'id' ],
    [ 'select id, name from authors where id = 1', [ 'authors', ['id', 'name'], { id => 1 } ], 'id' ],
    [ 'select * from authors where id = 1', [ 'authors', undef, 'id = 1' ], 'id' ],
    [ 'select id, name from authors where id = 1', [ 'authors', ['id', 'name'], 'id = 1' ], 'id' ],
    [ 'select * from books where id > 3', [ 'books', undef, 'id > 3' ], 'id' ],
    [ 'select id, title, year from books where title = \'Adventure\' and year = 1911', [ 'books',
            ['id', 'title', 'year'], { title => 'Adventure', year => 1911 } ], 'id' ],
);

plan tests => 1 + 4 * @sql_and_params;

# create sqlite db for test
my $_dbh = TestDB->create( 'sqlite' );

my $sqlite_db = $_dbh->file;

# delete sqlite file before finish
$SIG{__DIE__} = sub{ $_dbh->drop; warn $_[0]; exit; };


my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );
ok ( $db, 'DB object exists' );

my $i = 0;
foreach my $query ( @sql_and_params ) {
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

