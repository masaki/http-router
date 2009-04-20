use strict;
use Test::More tests => 17;
use Test::HTTP::Router;
use HTTP::Router::Declare;

my $router = router {
    resources 'Users';
};

is scalar @{[ $router->routes ]} => 16;

match_ok $router, '/users', { method => 'GET'  }, 'matched index';
match_ok $router, '/users', { method => 'POST' }, 'matched create';

match_ok $router, '/users/new', { method => 'GET' }, 'matched new';

match_ok $router, '/users/1', { method => 'GET'    }, 'matched show';
match_ok $router, '/users/1', { method => 'PUT'    }, 'matched update';
match_ok $router, '/users/1', { method => 'DELETE' }, 'matched destroy';

match_ok $router, '/users/1/edit',   { method => 'GET' }, 'matched edit';
match_ok $router, '/users/1/delete', { method => 'GET' }, 'matched delete';

# with format
match_ok $router, '/users.html', { method => 'GET'  }, 'matched formatted index';
match_ok $router, '/users.html', { method => 'POST' }, 'matched formatted create';

match_ok $router, '/users/new.html', { method => 'GET' }, 'matched formatted new';

match_ok $router, '/users/1.html', { method => 'GET'    }, 'matched formatted show';
match_ok $router, '/users/1.html', { method => 'PUT'    }, 'matched formatted update';
match_ok $router, '/users/1.html', { method => 'DELETE' }, 'matched formatted destroy';

match_ok $router, '/users/1/edit.html',   { method => 'GET' }, 'matched formatted edit';
match_ok $router, '/users/1/delete.html', { method => 'GET' }, 'matched formatted delete';
