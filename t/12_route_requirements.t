use t::Router;
use HTTP::Router::Route;

plan tests => 4 * blocks;

filters {
    params       => ['yaml'],
    requirements => ['eval'],
    results      => ['yaml'],
};

run {
    my $block = shift;
    my $name  = $block->name;
    my $route = HTTP::Router::Route->new(
        path         => $block->path,
        params       => $block->params,
        requirements => $block->requirements,
    );

    my $match = $route->match_with_expansions($block->input);
    ok $match, "ok $name";
    is $match->path => $block->input, "ok path $name";
    is_deeply $match->params => $block->results, "ok params $name";

    ok !$route->match_with_expansions($block->fake), "no requirements $name";
};

__END__
=== /archives/{year}/{month}
--- path: /archives/{year}/{month}
--- params
controller: Archive
action: by_month
--- requirements: { year => qr/^\d{4}$/, month => qr/^\d{2}$/ }
--- input: /archives/2008/12
--- results
controller: Archive
action: by_month
year: 2008
month: 12
--- fake: /archives/09/1

=== /users/{user_id}/entries/{entry_id}
--- path: /users/{user_id}/entries/{entry_id}
--- params
controller: User::Entry
action: show
--- requirements: { user_id => qr/^[a-z]+$/, entry_id => qr/^\d+$/ }
--- input: /users/masaki/entries/100
--- results
controller: User::Entry
action: show
user_id: masaki
entry_id: 100
--- fake: /users/masaki/entries/id100
