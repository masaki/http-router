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

    my $match = $route->match($block->input);
    ok $match, "ok $name";
    is $match->path => $block->input, "ok path $name";
    is_deeply $match->params => $block->results, "ok params $name";

    ok !$route->match($block->fake), "no match $name";
};

__END__
=== /
--- path: /
--- params
controller: Root
action: index
--- input: /
--- results
controller: Root
action: index
--- fake: /404

=== /account/login
--- path: /account/login
--- params
controller: Account
action: login
--- input: /account/login
--- results
controller: Account
action: login
--- fake: /account/404
