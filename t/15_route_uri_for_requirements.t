use t::Router;
use HTTP::Router::Route;

plan tests => 3;

my $route = HTTP::Router::Route->new(
    path         => '/archives/{year}/{month}',
    requirements => { year => qr/^\d{4}$/, month => qr/^\d{2}$/ },
);

is $route->uri_for({ year => 2008, month => 12 }) => '/archives/2008/12', "ok uri_for";
ok !$route->uri_for({}), "missing parameters";
ok !$route->uri_for({ year => 2009, month => 1 }), "invalid parameters";

