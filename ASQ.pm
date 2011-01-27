package DBIx::ASQ;

use strict;
use warnings;

use DBI;

BEGIN { *DEBUG = sub() { 0 } }

our ($VERSION, $AUTOLOAD);

$VERSION = 0.01;

# {} - conjunction - logic "and"
# [] - disjunction - logic "or"

my %CACHE;

{
    my %op = ( 
        ' like'         => [ 'like',        '%',    '%' ],
        ' not like'     => [ 'not like',    '%',    '%' ],
        ' begin'        => [ 'like',        '',     '%' ],
        ' not begin'    => [ 'not like',    '',     '%' ],
        ' end'          => [ 'like',        '%',    ''  ],
        ' not end'      => [ 'not like',    '%',    ''  ],
    );
    sub _where($$) { 
        my ($self, $where) = @_;

        my $where_str = '';
        if ( $where ) {
            $where_str = ref $where
            ? ' WHERE ' . join( ' AND ' =>
                (map {
                    my $str;
                    if ( /\s*(\w+)\s*([=<>]{1,2}| (not )?(like|begin|end))\s*/ ) {
                        if ( length $2 < 3 ) { $str = "$1 $2 ?" }
                        else {
                            $str = "$1 $op{$2}[0] ?";
                            $where->{$_} = $op{$2}[1] . $where->{$_} . $op{$2}[2];
                        }
                    }
                    else { $str = "$_ = ?" }
                    $str;
                    } keys %$where ) 
            ) : " WHERE $where";
        }

        return $where_str;
    }
}

sub _params($\%) {
    my ($self, $query) = @_;
    
    my $params = '';
    my @params;
    
    if ( $query->{sortby} ) {
        $params = ' ORDER BY ' . $self->{dbh}->quote_identifier( $query->{sortby} );
        $params .= ' ' . $query->{order} if $query->{order} and $query->{order} =~ /^\s*(?:de|a)sc\s*$/i;
    }
    
    if ( $query->{limit} && $query->{limit} =~ /^\d+$/ ) {
        $params .= ' LIMIT ?';
        if ( defined $query->{offset} && $query->{offset} =~ /^\d+$/ ) {
            $params .= ', ?';
            push @params, $query->{offset}, $query->{limit};
        }
        else {
            push @params, $query->{limit};
        }
    }

    return ( $params, @params );

}

sub _query_parameters {
    my ( $self, $is_add_fields) = (shift, shift);
    
    my ( $table, $fields, $where, $query );
    
    if ( @_ == 1 and ref $_[0] ) {
        $query = $_[0];
        ( $table, $fields, $where ) = @$query{qw/table fields where/};
    }
    else {
        ( $table, $fields, $where ) = $is_add_fields ? @_ : ($_[0], undef, $_[1]);
    }

    return ( $self->{dbh}->quote_identifier( $table ), $is_add_fields ? $fields : (), $where, $query );
}

sub new {
    my ( $class, $dsn ) = (shift, shift);
    my $user        = $_[0] || '';
    my $password    = $_[1] || '';
    my $attr        = $_[2] || { RaiseError => 1, AutoCommit => 1, PrintError => 0 };

    unless ( $CACHE{ "${dsn}_$user" } ) {
        
        if( my $dbh = DBI->connect( "dbi:" . $dsn, $user, $password, $attr ) ) {
            $CACHE{ "${dsn}_$user" } = bless { 
                dbh     => $dbh, 
                connect => { dsn => $dsn, user => $user, password => $password, attr => $attr },
            } => $class;
        }
        else {
            warn "Can't connect to database [$dsn]. Error message: [$DBI::errstr]";
        }
    }

    $CACHE{ "${dsn}_$user" };
}

sub insert {
    my ( $self, $table, $vars ) = @_;
    my @keys = keys %$vars;

    my $sql = "INSERT INTO $table (" . join( ', ' => (map { $self->{dbh}->quote_identifier( $_ ) } @keys) ) 
                . ') VALUES (' .  join( ', ' => ( ('?') x @keys ) ) . ')';

    my $sth = $self->query( $sql, values %$vars );
    $sth->_add_info( $self->{dbh} ) if $sth;

    return $sth;
}

sub update {
    my $self = shift;
    
    my ( $table, $vars, $where, $query ) = $self->_query_parameters( 1, @_ );
    
    my ($params, @params);
    ( $params, @params ) = $self->_params( $query) 
        if $query and $self->{dbh}{Driver}{Name} =~ /sqlite|mysql/i;
 
    my $sql = "UPDATE $table SET " 
                . join( ', ' => map { $self->{dbh}->quote_identifier( $_ ) . ' = ?' } keys %$vars);
    
    $sql .= $self->_where( $where ) if $where;
    $sql .= $params                 if $params;

    $self->query( $sql, values %$vars, ref $where ? values %$where : (), @params ) ? 1 : undef;
}

sub delete {
    my $self = shift;
 
    my ( $table, $where, $query ) = $self->_query_parameters( 0, @_ );
        
    my ($params, @params);
    ( $params, @params ) = $self->_params( $query ) if $query and $self->{dbh}{Driver}{Name} =~ /sqlite|mysql/i;
 
    my $sql = "DELETE FROM $table";
    
    $sql .= $self->_where( $where ) if $where;
    $sql .= $params                 if $params;

    $self->query( $sql, ref $where ? values( %$where ) : (), @params ) ? 1 : undef;
}

sub select {
    my $self = shift;
    
    my ( $table, $fields, $where, $query ) = $self->_query_parameters( 1, @_ );
   
    $fields = join ', ' => ( grep { $_ } @$fields ) if ref $fields;
    $fields ||= '*';

    my ($params, @params);
    ($params, @params) = $self->_params( $query ) if $query;

    my $sql = "SELECT $fields FROM $table";
    
    $sql .= $self->_where( $where ) if $where;
    $sql .= $params                 if $params;

    $self->query( $sql, ref $where ? values %$where : (), @params );
}

sub count {
    my $self = shift;
    
    my ( $table, $where ) = $self->_query_parameters( 0, @_ );
   
    my $sql = "SELECT count(*) FROM $table"; 
    
    $sql .= $self->_where( $where ) if $where;
    
    my $sth = $self->query( $sql, ref $where ? values %$where : () );

    return $sth ? $sth->fetchrow_array : undef;
}

sub query {
    my ( $self, $sql, @binds ) = @_;

    warn 'dsn: ' . $self->{connect}{dsn} . 
            "; sql: $sql; binds: [" 
                . join( ', ' => @binds ) . ']' if DEBUG;

    if( my $sth = $self->{dbh}->prepare( $sql ) ) {
        return DBIx::ASQ::sth->new($sth) if $sth->execute( @binds );
    }
    
    $self->{errstr} = $DBI::errstr;
    
    undef;
}

sub disconnect { 
    my $self = shift;

    warn 'Destroy database object [' . $self->{connect}{dsn}. ']' if DEBUG;

    delete $CACHE{ $self->{connect}{dsn} . '_' . $self->{connect}{user} };
    $self->{dbh}->disconnect(); 
}

sub DESTROY { 
    my $self = shift;
    $self->{dbh}->disconnect() if $self->{dbh}
}

sub AUTOLOAD {
    my $self = $_[0];

    die "No $AUTOLOAD class messod" if ref $self ne __PACKAGE__;

    (my $name = $AUTOLOAD) =~ s/^.+:://;

    my $sub = sub { my $s = shift; $s->{dbh}->$name( @_ ) };

    no strict 'refs';
    *{$AUTOLOAD} = $sub;
    use strict 'refs';
    goto &{$sub};
}

1;

package DBIx::ASQ::sth;

use strict;
use warnings;

our $AUTOLOAD;

sub new {
    my ( $class, $sth ) = @_;
    return bless [ $sth ] => $class;
}

sub _add_info {
    my ( $s, $dbh ) = @_;
    $s->[1] = $dbh;
}

sub hash {
    my $hr = shift->[0]->fetchrow_hashref( @_ ) || {};
    return wantarray ? %$hr : $hr;
}

sub array {
    my @a = shift->[0]->fetchrow_array( @_ );
    return wantarray ? @a : \@a;
}

sub fetchall { 
    my $s = shift; 
    my (@r, $r);
    while ( $r = $s->[0]->fetchrow_hashref ) { push @r, $r } 
    wantarray ? @r : \@r;
}

sub last_insert_id {
    my ($s, $col) = @_;
    
    die 'You can use last_insert_id methods only after insert method!' unless exists( $s->[1] ); 

    my $type = lc( $s->[1]->{Driver}->{Name} );

    my $id;
    if ( $type eq 'sqlite' ) {
        $id = $s->[1]->sqlite_last_insert_rowid();
    }
    elsif ( $type eq 'mysql' ) {
        $id = $s->[1]->{mysql_insertid};
    }
    elsif ( $type eq 'pg' ) {
        my $sth = $s->[1]->prepare( "select currval($col)" );
        $sth->execute();
        $id = ($sth->fetchrow_array);
    } 
    else {
        die q/Now, method doesn't support this database: / . $s->[1];
    }

    return $id;
}

sub AUTOLOAD {
    my $self = $_[0];

    die "No $AUTOLOAD class messod" if ref $self ne __PACKAGE__;

    (my $name = $AUTOLOAD) =~ s/^.+:://;

    my $sub = sub { my $s = shift; $s->[0]->$name( @_ ) };

    no strict 'refs';
    *{$AUTOLOAD} = $sub;
    use strict 'refs';
    goto &{$sub};
}

1;

__END__

=head1 NAME

DBIx::ASQ

=head1 VERSION

This documentation refers to <DBIx::ASQ> version 0.1

=head1 AUTHOR

<Anton Morozov>  (<anton@antonfin.kiev.ua>)

=head1 SYNOPSIS

        use DBIx::ASQ;

        my $dbh = DBIx::ASQ->new( "dbi:Pg:dbname=books", "postgres", "EqF$F@#23");

        my $rows = $dbh->select( "book_list", "title, author", { type => "roman" } )->fetchall_arrayref;

        $dbh->update( "authors", { name => 'Panov' }, { id => 1234 } ) 
            or warn( "Can't save info" . $dbh->strerr );

        $dbh->delete( "book_list", { title => 'Very old Book' } );

        $dbh->insert( "audiobooks", { title => 'The Secret City IV', author => 'Panov', year => 2007 } );

        my $sth = $dbh->query( "select * from audiobooks where id > 12 and (add_time > '2010-03-03' or upd_time < " . $dbq->quote( "2010-05-15" ) )

        @row_ary  = $sth->fetchrow_array;
        $ary_ref  = $sth->fetchrow_arrayref;
        $hash_ref = $sth->fetchrow_hashref;

        $ary_ref  = $sth->fetchall_arrayref;
        $ary_ref  = $sth->fetchall_arrayref( $slice, $max_rows );

        $hash_ref = $sth->fetchall_hashref( $key_field );

        # My love, return array of hashes with items
        $ary_hash_ref = $sth->fetchall;

=head1 DESCRIPTION

=head1 METHODS

=head1 LICENSE AND COPYRIGHT

    Copyright (c) 2011 (anton@antonfin.kiev.ua)
    All rights reserved.

=cut

