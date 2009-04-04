use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(request results) };

my $router = HTTP::Router->define(sub {
    $_->resource('account', sub {
        $_->resource('admin');
    });
});

is scalar @{[ $router->routes ]} => 24;

run {
    my $block = shift;
    my $req = create_request($block->request);

    my $match = $router->match($req);
    ok $match;
    cmp_deeply $match->params => $block->results;
};

__END__
=== create
--- request: { path => '/account/admin', method => 'POST' }
--- results: { controller => 'Admin', action => 'create' }

=== formatted create
--- request: { path => '/account/admin.html', method => 'POST' }
--- results: { controller => 'Admin', action => 'create', format => 'html' }

=== show
--- request: { path => '/account/admin', method => 'GET' }
--- results: { controller => 'Admin', action => 'show' }

=== formatted show
--- request: { path => '/account/admin.html', method => 'GET' }
--- results: { controller => 'Admin', action => 'show', format => 'html' }

=== update
--- request: { path => '/account/admin', method => 'PUT' }
--- results: { controller => 'Admin', action => 'update' }

=== formatted update
--- request: { path => '/account/admin.html', method => 'PUT' }
--- results: { controller => 'Admin', action => 'update', format => 'html' }

=== destroy
--- request: { path => '/account/admin', method => 'DELETE' }
--- results: { controller => 'Admin', action => 'destroy' }

=== formatted destroy
--- request: { path => '/account/admin.html', method => 'DELETE' }
--- results: { controller => 'Admin', action => 'destroy', format => 'html' }

=== new
--- request: { path => '/account/admin/new', method => 'GET' }
--- results: { controller => 'Admin', action => 'post' }

=== formatted new
--- request: { path => '/account/admin/new.html', method => 'GET' }
--- results: { controller => 'Admin', action => 'post', format => 'html' }

=== edit
--- request: { path => '/account/admin/edit', method => 'GET' }
--- results: { controller => 'Admin', action => 'edit' }

=== formatted edit
--- request: { path => '/account/admin/edit.html', method => 'GET' }
--- results: { controller => 'Admin', action => 'edit', format => 'html' }
