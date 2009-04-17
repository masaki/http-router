use strict;
use Test::More tests => 1;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resource 'Account' => then {
        resource 'Admin';
    };
};

is scalar @{[ $router->routes ]} => 28;
