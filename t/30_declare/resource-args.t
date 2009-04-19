use strict;
use Test::More tests => 6;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resource 'Admin', {
        controller => 'User::Admin',
        member     => { settings => 'GET' },
    };

    resource 'Account', { except => [qw(new edit delete)] };

    resource 'User', { only => [qw(show update)] };
};

is scalar @{[ $router->routes ]} => 28; # admin => 16, account => 8, user => 4

match_ok $router, '/admin/settings',      { method => 'GET' }, 'matched user defined action';
match_ok $router, '/admin/settings.html', { method => 'GET' }, 'matched user defined formatted action';

match_not_ok $router, '/account/edit', { method => 'GET' }, 'not matched excepted action';

match_ok     $router, '/user', { method => 'GET' },    'matched only action';
match_not_ok $router, '/user', { method => 'DELETE' }, 'not matched !only action';
