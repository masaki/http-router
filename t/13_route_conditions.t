use t::Router;
use HTTP::Router::Route;

plan tests => 2 * blocks;

filters {
    conditions => ['eval'],
    input      => ['eval'],
};

run {
    my $block = shift;
    my $name  = $block->name;
    my $route = HTTP::Router::Route->new(
        path       => $block->path,
        conditions => $block->conditions,
    );

    ok $route->match(@{ $block->input }), "ok $name";
    ok !$route->match($block->path), "undefined conditions $name";
};

__END__
=== simple condition
--- path: /
--- conditions: { method => 'GET' }
--- input: [ '/', { method => 'GET' } ]

=== array conditions
--- path: /
--- conditions: { method => ['GET', 'POST'] }
--- input: [ '/', { method => 'POST' } ]
