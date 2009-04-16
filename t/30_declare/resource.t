use strict;
use Test::More tests => 15;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resource 'Account';
};

is scalar @{[ $router->routes ]} => 14;

match_ok $router, '/account', { method => 'GET'    }, 'matched show';
match_ok $router, '/account', { method => 'POST'   }, 'matched create';
match_ok $router, '/account', { method => 'PUT'    }, 'matched update';
match_ok $router, '/account', { method => 'DELETE' }, 'matched destroy';

match_ok $router, '/account/new',    { method => 'GET' }, 'matched post';
match_ok $router, '/account/edit',   { method => 'GET' }, 'matched edit';
match_ok $router, '/account/delete', { method => 'GET' }, 'matched delete';

# with format
match_ok $router, '/account.html', { method => 'GET'    }, 'matched formatted show';
match_ok $router, '/account.html', { method => 'POST'   }, 'matched formatted create';
match_ok $router, '/account.html', { method => 'PUT'    }, 'matched formatted update';
match_ok $router, '/account.html', { method => 'DELETE' }, 'matched formatted destroy';

match_ok $router, '/account/new.html',    { method => 'GET' }, 'matched formatted post';
match_ok $router, '/account/edit.html',   { method => 'GET' }, 'matched formatted edit';
match_ok $router, '/account/delete.html', { method => 'GET' }, 'matched formatted delete';
