use t::Router;
use HTTP::Router::Route;

plan tests => 1 * blocks;

filters {
    args => ['yaml'],
};

run {
    my $block = shift;
    my $name  = $block->name;
    my $route = HTTP::Router::Route->new(
        path => $block->path,
    );

    is $route->uri_for($block->args) => $block->uri, "ok uri_for $name";
};

__END__
=== /
--- path: /
--- uri: /

=== /archives/{year}/{month} (no requirements)
--- path: /archives/{year}/{month}
--- args
year: 2008
month: 12
--- uri: /archives/2008/12
