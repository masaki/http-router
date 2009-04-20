use strict;
use Test::More tests => 8;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resources 'Users', {
        collection => { recent   => 'GET' },
        member     => { settings => 'GET' },
    };

    resources 'Articles', { except => [qw(edit delete)] };
    resources 'Entries',  { only => [qw(show update)] };
};

is scalar @{[ $router->routes ]} => 36; # users => 20, articles => 12, entries => 4

match_ok $router, '/users/recent',      { method => 'GET' }, 'matched user defined action';
match_ok $router, '/users/recent.html', { method => 'GET' }, 'matched user defined formatted action';

match_ok $router, '/users/1/settings',      { method => 'GET' }, 'matched user defined action';
match_ok $router, '/users/1/settings.html', { method => 'GET' }, 'matched user defined formatted action';

match_not_ok $router, '/articles/1/edit', { method => 'GET' }, 'not matched excepted action';

match_ok     $router, '/entries/1', { method => 'GET' },    'matched only action';
match_not_ok $router, '/entries/1', { method => 'DELETE' }, 'not matched !only action';
