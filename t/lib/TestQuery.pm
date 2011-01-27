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
    [ 'select * from books where id > 3', [ 'books', '*', { 'id > ' => 3 } ], 'id' ],
    [ 'select * from books where id < 3', [ 'books', undef, { 'id <'  => 3 } ], 'id' ],
    [ 'select * from books where id <= 3', [ 'books', '*', { 'id <='  => 3 } ], 'id' ],
    [ 'select * from books where id >= 3', [ 'books', undef, { 'id >='  => 3 } ], 'id' ],
    [ 'select * from books where id <> 3', [ 'books', '*', { 'id <>'  => 3 } ], 'id' ],

    [ q/select id, title, year from books where title = 'Adventure' and year = 1911/, 
        [ 'books', ['id', 'title', 'year'], { title => 'Adventure', year => 1911 } ], 'id' ],
    [ q/select id, title, year from books where title = 'Adventure' and year = 1911/, 
        [ 'books', ['id', 'title', 'year'], q/title = 'Adventure' and year = 1911/ ], 'id' ],

    [ q/select id, title, year from books where author_id = 1 and year <= 1912/, 
        [ 'books', ['id', 'title', 'year'], { author_id => 1, 'year<=' => 1912 } ], 'id' ],
    [ q/select id, title, year from books where author_id = 1 and year <= 1912/, 
        [ 'books', ['id', 'title', 'year'], q/author_id = 1 and year <= 1912/ ], 'id' ],

    # like
    [ q/select * from books where title like '%Sea%'/,
        [ 'books', '*', { 'title like' => 'Sea' } ], 'id' ],

    [ q/select * from books where title like '%Sea%'/,
        [ 'books', '*', q/title like '%Sea%'/ ], 'id' ],

    # not like
    [ q/select * from books where title not like '%Sea%'/,
        [ 'books', '*', { 'title not like' => 'Sea' } ], 'id' ],

    # begin
    [ q/select * from books where title like 'The%'/,
        [ 'books', '*', { 'title begin' => 'The' } ], 'id' ],

    # not begin
    [ q/select * from books where title not like 'The%'/,
        [ 'books', '*', { 'title not begin' => 'The' } ], 'id' ],

    # end
    [ q/select * from books where title like '%er'/,
        [ 'books', '*', { 'title end' => 'er' } ], 'id' ],

    # not end
    [ q/select * from books where title not like '%er'/,
        [ 'books', '*', { 'title not end' => 'er' } ], 'id' ],
);

our @INSERT = (
    [ 'books',      { title => 'That Spot', year => 1908, author_id => 1 } ], 
    [ 'authors',    { name => 'Ernest Miller Hemingway', description => 'Was an American author and journalist' } ],
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
