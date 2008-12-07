use t::Router;
use HTTP::Router::Route;

plan tests => 4 * blocks;

filters {
    params  => ['yaml'],
    results => ['yaml'],
};

run {
    my $block = shift;
    my $name  = $block->name;
    my $route = HTTP::Router::Route->new(
        path   => $block->path,
        params => $block->params,
    );

    my $match = $route->match_with_expansions($block->input);
    ok $match, "ok $name";
    is $match->path => $block->input, "ok path $name";
    is_deeply $match->params => $block->results, "ok params $name";

    ok !$route->match_with_expansions($block->fake), "no match $name";
};

__END__
=== /archives/{year}/{month}
--- path: /archives/{year}/{month}
--- params
controller: Archive
action: by_month
--- input: /archives/2008/12
--- results
controller: Archive
action: by_month
year: 2008
month: 12
--- fake: /archives/2008/12/31

=== /users/{user_id}/entries/{entry_id}
--- path: /users/{user_id}/entries/{entry_id}
--- params
controller: User::Entry
action: show
--- input: /users/masaki/entries/100
--- results
controller: User::Entry
action: show
user_id: masaki
entry_id: 100
--- fake: /users/masaki/comments/100
