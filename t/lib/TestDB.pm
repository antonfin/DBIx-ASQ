package TestDB;

use strict;
use warnings;

use DBI;
use File::Basename 'dirname';

my $sqlite_db_standart_t1 = <<'T1';
    create table books(
        id INTEGER PRIMARY KEY,
        title  VARCHAR(128) NOT NULL,
        description TEXT,
        author_id   INTEGER,
        year    SHORT INTEGER
    );
T1

my $sqlite_db_standart_t2 = <<'T2';
    create table authors (
        id INTEGER PRIMARY KEY,
        name VARCHAR(128) NOT NULL,
        description TEXT
    );
T2

my @inserts = (
    q/insert into authors (name, description) values ('Jack London', 'American author, journalist, and social activist')/,
    q/insert into authors (name, description) values ('Richard David Bach', 'American writer. He is widely known as the author of the hugely popular 1970s best-sellers Jonathan Livingston Seagull, Illusions: The Adventures of a Reluctant Messiah, and others.')/,

    q/insert into books (title, author_id, year ) values ('The Sea-Wolf', 1, 1904)/,
    q/insert into books (title, author_id, year ) values ('The Iron Heel', 1, 1908)/,
    q/insert into books (title, author_id, year ) values ('Adventure', 1, 1911)/,
    q/insert into books (title, author_id, year ) values ('The Scarlet Plague', 1, 1912)/,
    q/insert into books (title, author_id, year ) values ('A Son of the Sun', 1, 1912)/,
    q/insert into books (title, author_id, year ) values ('The Star Rover', 1, 1915)/,
    q/insert into books (title, author_id, year ) values ('Hearts of Three', 1, 1920)/,

    q/insert into books (title, description, author_id, year) values ('Jonathan Livingston Seagull', 'is a fable in novella form about a seagull learning about life and flight', 2, 1970)/,
    q/insert into books (title, description, author_id, year) values ('The Bridge Across Forever', 'A Love Story', 2, 1984)/,
    q/insert into books (title, author_id, year) values ('Out of My Mind', 2, 2000)/,
);

my @sqlite_db_standart = ( $sqlite_db_standart_t1, $sqlite_db_standart_t2, @inserts );

sub create {
    my ( $class, $type, $db, $user, $pwd ) = @_;

    my $dbh;
    my $_type = lc($type);
    if ( $_type eq 'sqlite' ) {

        unless ( $db ) {
            $db = dirname( __FILE__ ) . '/test' . rand(99999) . '.db';
            unlink( $db ) or die $! if -f $db;
        }

        $dbh = DBI->connect( "dbi:SQLite:dbname=$db", '', '', { PrintError => 1 } );
        $dbh->do( $_ ) for @sqlite_db_standart;
    }
    
    bless { dbh => $dbh, db => $db, user => $user, pwd => $pwd, type => $_type } => $class;
}

sub new {
    my ( $class, $type, $db, $user, $pwd ) = @_;
 
    my $dbh;
    my $_type = lc($type);
    if ( $_type eq 'sqlite' ) {
        $dbh = DBI->connect( "dbi:SQLite:dbname=$db", "", "" );
    }

    bless { dbh => $dbh, db => $db, user => $user, pwd => $pwd, type => $_type } => $class;
}

sub prepare { shift->{dbh}->prepare( @_ ) }

sub file {
    my $self = shift;
    $self->{type} eq 'sqlite' ? $self->{db} : undef
}

sub disconnect {
    my $self = shift;
    my $dbh = delete( $self->{dbh} );
    $dbh->disconnect();
    return $self;
}

sub drop {
    my $self = shift;
    if ( $self->{type} eq 'sqlite' ) { unlink $self->{db} };
}

1;

__END__

=head1 NAME

TestDB.pm - module for help DBIx::ASQ testing

=head1 VERSION

This documentation refers to <TestDB> version 0.1

=head1 AUTHOR

<Anton Morozov>  (<anton@antonfin.kiev.ua>)

=head1 SYNOPSIS

use TestDB;

=head1 DESCRIPTION

=head1 METHODS

=cut

=head1 LICENSE AND COPYRIGHT

    Copyright (c) 2010 (anton@antonfin.kiev.ua)
    All rights reserved.

=cut

