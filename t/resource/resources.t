use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(request results) };

my $router = HTTP::Router->define(sub {
    $_->resources('Users');
});

is scalar @{[ $router->routes ]} => blocks;

run {
    my $block = shift;
    my $req = create_request($block->request);

    my $match = $router->match($req);
    ok $match;
    cmp_deeply $match->params => $block->results;
};

__END__
=== index
--- request: { path => '/users', method => 'GET' }
--- results: { controller => 'Users', action => 'index' }

=== formatted index
--- request: { path => '/users.html', method => 'GET' }
--- results: { controller => 'Users', action => 'index', format => 'html' }

=== new
--- request: { path => '/users/new', method => 'GET' }
--- results: { controller => 'Users', action => 'post' }

=== formatted new
--- request: { path => '/users/new.html', method => 'GET' }
--- results: { controller => 'Users', action => 'post', format => 'html' }

=== create
--- request: { path => '/users', method => 'POST' }
--- results: { controller => 'Users', action => 'create' }

=== formatted create
--- request: { path => '/users.html', method => 'POST' }
--- results: { controller => 'Users', action => 'create', format => 'html' }

=== show
--- request: { path => '/users/10', method => 'GET' }
--- results: { controller => 'Users', action => 'show', user_id => 10 }

=== formatted show
--- request: { path => '/users/10.html', method => 'GET' }
--- results: { controller => 'Users', action => 'show', user_id => 10, format => 'html' }

=== edit
--- request: { path => '/users/10/edit', method => 'GET' }
--- results: { controller => 'Users', action => 'edit', user_id => 10 }

=== formatted edit
--- request: { path => '/users/10/edit.html', method => 'GET' }
--- results: { controller => 'Users', action => 'edit', user_id => 10, format => 'html' }

=== update
--- request: { path => '/users/10', method => 'PUT' }
--- results: { controller => 'Users', action => 'update', user_id => 10 }

=== formatted update
--- request: { path => '/users/10.html', method => 'PUT' }
--- results: { controller => 'Users', action => 'update', user_id => 10, format => 'html' }

=== destroy
--- request: { path => '/users/10', method => 'DELETE' }
--- results: { controller => 'Users', action => 'destroy', user_id => 10 }

=== formatted destroy
--- request: { path => '/users/10.html', method => 'DELETE' }
--- results: { controller => 'Users', action => 'destroy', user_id => 10, format => 'html' }
