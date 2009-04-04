use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(params conditions request results) };

my $router = HTTP::Router->define(sub {
    $_->match('/account', { method => 'GET' })->to({ controller => 'account' }, sub {
        while (my $block = next_block) {
            $_->match($block->path, $block->conditions)->to($block->params);
        }
    });
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
===
--- path: /login
--- params: { action => 'login' }
--- request: { path => '/account/login', method => 'GET' }
--- results: { controller => 'account', action => 'login' }

===
--- path: /logout
--- params: { action => 'logout' }
--- request: { path => '/account/logout', method => 'GET' }
--- results: { controller => 'account', action => 'logout' }
