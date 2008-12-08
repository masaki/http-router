use t::Router;
use HTTP::Router::Route;

plan tests => 3 * blocks;

filters {
    requirements => ['eval'],
    args         => ['yaml'],
    fake_args    => ['yaml'],
};

run {
    my $block = shift;
    my $name  = $block->name;
    my $route = HTTP::Router::Route->new(
        path         => $block->path,
        requirements => $block->requirements,
    );

    is $route->uri_for($block->args) => $block->uri, "ok uri_for $name";
    ok !$route->uri_for, "missing parameters $name";
    ok !$route->uri_for($block->fake_args), "invalid parameters $name";
};

__END__
=== /archives/{year}/{month}
--- path: /archives/{year}/{month}
--- requirements: { year => qr/^\d{4}$/, month => qr/^\d{2}$/ }
--- args
year: 2008
month: 12
--- uri: /archives/2008/12
--- fake_args
year: 2009
month: 1
