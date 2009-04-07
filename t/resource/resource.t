use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;
use HTTP::Router::Resources;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(request results) };

my $router = HTTP::Router->define(sub {
    $_->resource('Account');
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
=== create
--- request: { path => '/account', method => 'POST' }
--- results: { controller => 'Account', action => 'create' }

=== formatted create
--- request: { path => '/account.html', method => 'POST' }
--- results: { controller => 'Account', action => 'create', format => 'html' }

=== show
--- request: { path => '/account', method => 'GET' }
--- results: { controller => 'Account', action => 'show' }

=== formatted show
--- request: { path => '/account.html', method => 'GET' }
--- results: { controller => 'Account', action => 'show', format => 'html' }

=== update
--- request: { path => '/account', method => 'PUT' }
--- results: { controller => 'Account', action => 'update' }

=== formatted update
--- request: { path => '/account.html', method => 'PUT' }
--- results: { controller => 'Account', action => 'update', format => 'html' }

=== destroy
--- request: { path => '/account', method => 'DELETE' }
--- results: { controller => 'Account', action => 'destroy' }

=== formatted destroy
--- request: { path => '/account.html', method => 'DELETE' }
--- results: { controller => 'Account', action => 'destroy', format => 'html' }

=== new
--- request: { path => '/account/new', method => 'GET' }
--- results: { controller => 'Account', action => 'post' }

=== formatted new
--- request: { path => '/account/new.html', method => 'GET' }
--- results: { controller => 'Account', action => 'post', format => 'html' }

=== edit
--- request: { path => '/account/edit', method => 'GET' }
--- results: { controller => 'Account', action => 'edit' }

=== formatted edit
--- request: { path => '/account/edit.html', method => 'GET' }
--- results: { controller => 'Account', action => 'edit', format => 'html' }
