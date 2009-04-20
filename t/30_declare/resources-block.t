use strict;
use Test::More tests => 8;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resources 'Users', { collection => { recent => 'GET' }, member => { settings => 'GET' } } => then {
        resources 'Articles';
        resources 'Entries',  { only => [qw(show update)] };
    };
};

is scalar @{[ $router->routes ]} => 40;

match_ok $router, '/users',            { method => 'GET' };
match_ok $router, '/users/recent',     { method => 'GET' };
match_ok $router, '/users/1/settings', { method => 'GET' };

match_ok $router, '/users/1/articles', { method => 'GET'  };
match_ok $router, '/users/1/articles', { method => 'POST' };

match_ok     $router, '/users/1/entries/1', { method => 'GET'    };
match_not_ok $router, '/users/1/entries/1', { method => 'DELETE' };
