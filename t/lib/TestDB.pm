package TestDB;

use strict;
use warnings;

use DBI;
use File::Basename 'dirname';

my $sqlite_db_standart_t1 = <<T1;
    create table books(
        id INTEGER PRIMARY KEY,
        title  VARCHAR(128) NOT NULL,
        description TEXT,
        author_id   INTEGER,
        year    SHORT INTEGER
    );
T1

my $sqlite_db_standart_t2 = <<T2;
    create table authors (
        id INTEGER PRIMARY KEY,
        name VARCHAR(128) NOT NULL,
        description TEXT
    );
T2

my @inserts = (
    "insert into authors (name, description) values ('Jack London', 'American author, journalist, and social activist')",
    "insert into authors (name, description) values ('Richard David Bach', 'American writer. He is widely known as the author of the hugely popular 1970s best-sellers Jonathan Livingston Seagull, Illusions: The Adventures of a Reluctant Messiah, and others.')",
    "insert into books (title, author_id, year ) values ('The Sea-Wolf', 1, 1904)",
    "insert into books (title, author_id, year ) values ('Adventure', 1, 1911)",
    "insert into books (title, author_id, year ) values ('The Star Rover', 1, 1915)",
    "insert into books (title, author_id, year ) values ('Hearts of Three', 1, 1920)",
    "insert into books (title, description, author_id, year) values ('Jonathan Livingston Seagull', 'is a fable in novella form about a seagull learning about life and flight', 2, 1970)"
);

my @sqlite_db_standart = ( $sqlite_db_standart_t1, $sqlite_db_standart_t2, @inserts );

sub new_db {
    my ( $class, $type, $db, $user, $pwd ) = @_;

    my $dbh;
    my $_type = lc($type);
    if ( $_type eq 'sqlite' ) {

        unless ( $db ) {
            my $tmp_dir = dirname( __FILE__ );
            $db  =  $tmp_dir . '/test.db';
        }

        unlink( $db ) or die $! if -f $db;

        $dbh = DBI->connect( "dbi:SQLite:dbname=$db", "", "" );
        $dbh->do( $_ ) or warn $dbh->errstr . "\n" for @sqlite_db_standart;
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
}

sub drop {
    my $self = shift;
    if ( $self->{type} eq 'sqlite' ) { unlink $self->{db} };
}

1;

__END__

=head1 NAME

TestDB.pm - module for help DB testing

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

