package TestQuery;

our @sql_and_params = (
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

1;

__END__

=head1 NAME

TestQuery   - module for help DBIx::ASQ testing

=head1 VERSION

This documentation refers to <TestQuery> version 0.1

=head1 AUTHOR

<Anton Morozov>  (<anton@antonfin.kiev.ua>)

=head1 SYNOPSIS

use TestQuery;

=head1 DESCRIPTION

=head1 METHODS

=cut

=head1 LICENSE AND COPYRIGHT

    Copyright (c) 2010 (anton@antonfin.kiev.ua)
    All rights reserved.

=cut
