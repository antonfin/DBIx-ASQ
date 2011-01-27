#
#===============================================================================
#
#  DESCRIPTION:  check count method
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

use Test::More tests => 54;
use DBIx::ASQ;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use TestDB;

# create sqlite db for test
my $_dbh = TestDB->create( 'sqlite' );

my $sqlite_db = $_dbh->file;

$SIG{__DIE__} = sub{ $_dbh->drop; warn $_[0]; exit; };


my $sth = $_dbh->prepare( "select count(*) from authors" );
$sth->execute();
my ($_c1) = $sth->fetchrow_array();
ok( $_c1, "Items in the authors table exists" );

# where id = 3
$sth = $_dbh->prepare( "select count(*) from books where id = ?" );
$sth->execute(3);
my ($_c2) = $sth->fetchrow_array();
ok( $_c2, "Item where id = 3 in the books table exists" );

# where id >= 3
$sth = $_dbh->prepare( "select count(*) from books where id >= ?" );
$sth->execute(3);
my ($_c3) = $sth->fetchrow_array();
ok( $_c3, "Items where id >= 3 in the books table exists" );

# where author_id = 1 and year = 1911
$sth = $_dbh->prepare( "select count(*) from books where author_id = ? and year = ?" );
$sth->execute( 1, 1911 );
my ($_c4) = $sth->fetchrow_array();
ok( $_c4, "Items where author_id = 1 and year = 1911 in the books table exists" );

# where author_id = 999
$sth = $_dbh->prepare( "select count(*) from books where author_id = ?" );
$sth->execute(999);
my ($_c5) = $sth->fetchrow_array();
is( $_c5, 0, "Items where author_id = 999 in the books table doesn't exist" );

# where year > 1911
$sth = $_dbh->prepare( "select count(*) from books where year > ?" );
$sth->execute( 1911 );
my ($_c6) = $sth->fetchrow_array();
ok( $_c6, "Items where year > 1911 in the books table exists" );

# where year < 1911
$sth = $_dbh->prepare( "select count(*) from books where year < ?" );
$sth->execute( 1911 );
my ($_c7) = $sth->fetchrow_array();
ok( $_c7, "Items where year < 1911 in the books table exists" );

# where year =< 1911
$sth = $_dbh->prepare( "select count(*) from books where year <= ?" );
$sth->execute( 1911 );
my ($_c8) = $sth->fetchrow_array();
ok( $_c8, "Items where year =< 1911 in the books table exists" );

# where year like %19%
$sth = $_dbh->prepare( "select count(*) from books where year like ?" );
$sth->execute( '%91%' );
my ($_c9) = $sth->fetchrow_array();
ok( $_c9, "Items where year like %91% in the books table exists" );

# where year begin 191%
$sth = $_dbh->prepare( "select count(*) from books where year like ?" );
$sth->execute( '191%' );
my ($_c10) = $sth->fetchrow_array();
ok( $_c10, "Items where year like 19% in the books table exists" );

# where year end %11
$sth = $_dbh->prepare( "select count(*) from books where year like ?" );
$sth->execute( '%11' );
my ($_c11) = $sth->fetchrow_array();
ok( $_c11, "Items where year like %11 in the books table exists" );

# not

# where year not like %19%
$sth = $_dbh->prepare( "select count(*) from books where not year like ?" );
$sth->execute( '%91%' );
my ($_c12) = $sth->fetchrow_array();
ok( $_c12, "Items where year not like %91% in the books table exists" );

# where year not begin 191%
$sth = $_dbh->prepare( "select count(*) from books where year not like ?" );
$sth->execute( '191%' );
my ($_c13) = $sth->fetchrow_array();
ok( $_c13, "Items where year not like 191% in the books table exists" );

# where year not end %11
$sth = $_dbh->prepare( "select count(*) from books where year not like ?" );
$sth->execute( '%11' );
my ($_c14) = $sth->fetchrow_array();
ok( $_c14, "Items where year not like %11 in the books table exists" );



$sth->finish;

$_dbh->disconnect();

# MAIN TEST

my $db = DBIx::ASQ->new( "SQLite:dbname=$sqlite_db" );

ok( $db, "DB object exists" );

my $c11 = $db->count( 'authors' );
ok( $c11, "Test count 1" );
is( $c11, $_c1, "Test count 2" );

my $c12 = $db->count( { table => 'authors' } );
ok( $c12, "Test count 3" );
is( $c12, $_c1, "Test count 4" );

my $c21 = $db->count( 'books', { id => 3 } );
ok( $c21, "Test count 5" );
is( $c21, $_c2, "Test count 6" );

my $c22 = $db->count( { table => 'books', where => { id => 3 } } );
ok( $c22, "Test count 7" );
is( $c22, $_c2, "Test count 8" );

my $c31 = $db->count( 'books', 'id>=3' );
ok( $c31, "Test count 9" );
is( $c31, $_c3, "Test count 10" );

my $c32 = $db->count( { table => 'books', where => 'id>=3' } );
ok( $c32, "Test count 11" );
is( $c32, $_c3, "Test count 12" );

my $c41 = $db->count( 'books', 'author_id = 1 and year = 1911' );
ok( $c41, "Test count 13" );
is( $c41, $_c4, "Test count 14" );

my $c42 = $db->count( { table => 'books', where => { author_id => 1, year => 1911 } } );
ok( $c42, "Test count 15" );
is( $c42, $_c4, "Test count 16" );

my $c51 = $db->count( 'books', 'author_id = 999' );
ok( defined $c51, "Test count 17" );
is( $c51, $_c5, "Test count 18" );

my $c52 = $db->count( { table => 'books', where => { author_id => 999 } } );
ok( defined $c52, "Test count 19" );
is( $c52, $_c5, "Test count 20" );

my $c62 = $db->count( { table => 'books', where => { 'year > ' => 1911 } } );
ok( defined $c62, "Test count 21" );
is( $c62, $_c6, "Test count 22" );

my $c72 = $db->count( { table => 'books', where => { 'year < ' => 1911 } } );
ok( defined $c72, "Test count 23" );
is( $c72, $_c7, "Test count 24" );

my $c82 = $db->count( { table => 'books', where => { 'year <= ' => 1911 } } );
ok( defined $c82, "Test count 25" );
is( $c82, $_c8, "Test count 26" );

my $c92 = $db->count( { table => 'books', where => { 'year like ' => '91' } } );
ok( defined $c92, "Test count 27" );
is( $c92, $_c9, "Test count 28" );

my $c102 = $db->count( { table => 'books', where => { 'year begin' => '191' } } );
ok( defined $c102, "Test count 29" );
is( $c102, $_c10, "Test count 30" );

my $c112 = $db->count( { table => 'books', where => { 'year end ' => '11' } } );
ok( defined $c112, "Test count 31" );
is( $c112, $_c11, "Test count 32" );

# NOT

my $c122 = $db->count( { table => 'books', where => { 'year not like ' => '91' } } );
ok( defined $c122, "Test count 33" );
is( $c122, $_c12, "Test count 34" );

my $c132 = $db->count( { table => 'books', where => { 'year not begin ' => '191' } } );
ok( defined $c132, "Test count 35" );
is( $c132, $_c13, "Test count 36" );

my $c142 = $db->count( { table => 'books', where => { 'year not end' => '11' } } );
ok( defined $c142, "Test count 37" );
is( $c142, $_c14, "Test count 38" );

ok( $db->disconnect(), "Close DB" );

# delete sqlite db
$_dbh->drop();

1;

