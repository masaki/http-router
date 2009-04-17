use strict;
use Test::More tests => 7;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resource 'Admin', {
        controller => 'User::Admin',
        member     => { settings => 'GET' },
    };

    resource 'Account', { except => [qw(post edit delete)] };

    resource 'User', { only => [qw(show update)] };
};

is scalar @{[ $router->routes ]} => 28; # admin => 14+2, account => 8, user => 4

match_ok $router, '/admin/settings',      { method => 'GET' }, 'matched user defined action';
match_ok $router, '/admim/settings.html', { method => 'GET' }, 'matched user defined formatted action';

match_not_ok $router, '/account/edit', { method => 'GET' };

match_ok $router, '/user/foobar', { method => 'GET' };
match_not_ok $router, '/user', { method => 'GET' };
match_not_ok $router, '/user/foobar', { method => 'DELETE' };
