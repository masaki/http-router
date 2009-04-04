use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(request results) };

my $router = HTTP::Router->define(sub {
    $_->resources('members', {
        controller => 'Users',
        collection => { login => 'POST', logout => ['GET', 'POST'] },
        member     => { settings => 'GET' },
    });
});

is scalar @{[ $router->routes ]} => 14 + 6;

run {
    my $block = shift;
    my $req = create_request($block->request);

    my $match = $router->match($req);
    ok $match;
    cmp_deeply $match->params => $block->results;
};

__END__
=== index
--- request: { path => '/members', method => 'GET' }
--- results: { controller => 'Users', action => 'index' }

=== formatted index
--- request: { path => '/members.html', method => 'GET' }
--- results: { controller => 'Users', action => 'index', format => 'html' }

=== login
--- request: { path => '/members/login', method => 'POST' }
--- results: { controller => 'Users', action => 'login' }

=== formatted login
--- request: { path => '/members/login.html', method => 'POST' }
--- results: { controller => 'Users', action => 'login', format => 'html' }

=== logout
--- request: { path => '/members/logout', method => 'GET' }
--- results: { controller => 'Users', action => 'logout' }

=== formatted logout
--- request: { path => '/members/logout.html', method => 'GET' }
--- results: { controller => 'Users', action => 'logout', format => 'html' }

=== settings
--- request: { path => '/members/10/settings', method => 'GET' }
--- results: { controller => 'Users', action => 'settings', member_id => 10 }

=== formatted settings
--- request: { path => '/members/10/settings.html', method => 'GET' }
--- results: { controller => 'Users', action => 'settings', member_id => 10, format => 'html' }
