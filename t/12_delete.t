#
#===============================================================================
#
#         FILE:  Fin-DB-10.t
#
#  DESCRIPTION:  check delete function (1)
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Anton Morozov (anton@antonfin.kiev.ua)
#      COMPANY:  Sunny Mobile
#      VERSION:  1.0
#      CREATED:  17.09.2010 09:17:06
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 17;
use DBIx::ASQ;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use TestDB;

# create sqlite db for test
my $_dbh = TestDB->create( 'sqlite' );

my $sqlite_db = $_dbh->file;

$SIG{__DIE__} = sub{ $_dbh->drop; warn $_[0]; exit; };

my $sth = $_dbh->prepare( 'select * from authors' );
$sth->execute();
my $authors_sel = $sth->fetchall_arrayref();
ok( @$authors_sel, 'Items in the authors table exists' );

# where id = 3
$sth = $_dbh->prepare( 'select * from books where id = ?' );
$sth->execute(3);
my $books_sel1 = $sth->fetchall_arrayref();
ok( @$books_sel1, 'Item where id = 3 in the books table exists' );

# where id > 4
$sth = $_dbh->prepare( 'select * from books where id > ?' );
$sth->execute(4);
my $books_sel2 = $sth->fetchall_arrayref();
ok( @$books_sel2, 'Items where id > 4 in the books table exists' );

# where id < 2
$sth = $_dbh->prepare( 'select * from books where id < ?' );
$sth->execute(2);
my $books_sel3 = $sth->fetchall_arrayref();
ok( @$books_sel3, 'Items where id < 2 in the books table exists' );

$_dbh->disconnect();

# MAIN TEST

my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );

ok( $db, 'DB object exists' );

# delete all from 'authors' table
ok( $db->delete( 'authors' ), 'Test delete 1' );

# delete somethink from 'books' table
ok( $db->delete( 'books', { id => 3 } ), 'Test delete 2' );

ok( $db->delete( 'books', { 'id >' => 4 } ), 'Test delete 3' );

ok( $db->delete( { table => 'books',  where => { 'id<' => 2 } } ), 'Test delete 4' );

ok( $db->disconnect(), 'Close DB' );

$_dbh = TestDB->new( 'sqlite', $sqlite_db );

$sth = $_dbh->prepare( 'select * from authors' );
$sth->execute();
$authors_sel = $sth->fetchall_arrayref();
ok( !@$authors_sel, 'Items in the authors table does not exist' );

# where id = 3
$sth = $_dbh->prepare( 'select * from books where id = ?' );
$sth->execute(3);
$books_sel1 = $sth->fetchall_arrayref();
ok( !@$books_sel1, 'Item where id = 3 in the books table does not exist' );

# where id > 4
$sth = $_dbh->prepare( 'select * from books where id > ?' );
$sth->execute(4);
$books_sel2 = $sth->fetchall_arrayref();
ok( !@$books_sel2, 'Items where id > 4 in the books table does not exist' );

# where id < 2
$sth = $_dbh->prepare( 'select * from books where id < ?' );
$sth->execute(2);
$books_sel3 = $sth->fetchall_arrayref();
ok( !@$books_sel3, 'Items where id < 2 in the books table does not exist' );

# check in the books table items with id = 2 and id = 4;
$sth = $_dbh->prepare( 'select id from books' );
$sth->execute();
my $books_sel4 = $sth->fetchall_arrayref();
ok( @$books_sel4, 'Items in the books table exists' );
ok ( (grep { $_->[0] == 2 } @$books_sel4) ? 1 : 0, 'Find book with id = 2' );
ok ( (grep { $_->[0] == 4 } @$books_sel4) ? 1 : 0, 'Find book with id = 4' );

$_dbh->disconnect();

# delete sqlite db
$_dbh->drop();

1;

