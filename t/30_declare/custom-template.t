use strict;
use Test::More tests => 8;
use Test::HTTP::Router;
use HTTP::Router::Declare 't::StaticPathTemplate';

my $router = router {
    match '/' => to { controller => 'Root', action => 'index' };

    match '/home', { method => 'GET' }
        => to { controller => 'Home', action => 'show' };
    match '/date/{year}' => to { controller => 'Date', action => 'by_year' };

    match '/{controller}/{action}/{id}';
};

is scalar @{[ $router->routes ]} => 4;

path_ok $router, '/';

match_not_ok $router, '/home', { method => 'POST' };
match_ok $router, '/home', { method => 'GET' };

path_not_ok $router, '/date/2009';
path_ok $router, '/date/{year}';

path_not_ok $router, '/foo/bar/baz';
path_ok $router, '/{controller}/{action}/{id}';
