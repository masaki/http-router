use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(request results) };

my $router = HTTP::Router->define(sub {
    $_->resource('admin', {
        controller => 'User::Admin',
        member     => { settings => 'GET' },
    });
});

is scalar @{[ $router->routes ]} => 12 + 2;

run {
    my $block = shift;
    my $req = create_request($block->request);

    my $match = $router->match($req);
    ok $match;
    cmp_deeply $match->params => $block->results;
};

__END__
=== show
--- request: { path => '/admin', method => 'GET' }
--- results: { controller => 'User::Admin', action => 'show' }

=== formatted show
--- request: { path => '/admin.html', method => 'GET' }
--- results: { controller => 'User::Admin', action => 'show', format => 'html' }

=== settings
--- request: { path => '/admin/settings', method => 'GET' }
--- results: { controller => 'User::Admin', action => 'settings' }

=== formatted settings
--- request: { path => '/admin/settings.html', method => 'GET' }
--- results: { controller => 'User::Admin', action => 'settings', format => 'html' }
