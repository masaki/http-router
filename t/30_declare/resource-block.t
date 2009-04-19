use strict;
use Test::More tests => 8;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resource 'Account', { member => { settings => 'GET' } } => then {
        resource 'Admin';
        resource 'User', { only => [qw(show update)] };
    };
};

is scalar @{[ $router->routes ]} => 34;

match_ok $router, '/account', { method => 'GET' };
match_ok $router, '/account', { method => 'POST' };
match_ok $router, '/account/settings', { method => 'GET' };

match_ok $router, '/account/admin', { method => 'GET' };
match_ok $router, '/account/admin', { method => 'POST' };

match_ok $router, '/account/user', { method => 'GET' };
match_not_ok $router, '/account/user', { method => 'POST' };
