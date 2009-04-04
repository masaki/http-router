use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(params conditions request results) };

my $router = HTTP::Router->define(sub {
    $_->with({ controller => 'users' }, sub {
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
--- request: { path => '/login' }
--- results: { controller => 'users', action => 'login' }

===
--- path: /logout
--- params: { action => 'logout' }
--- request: { path => '/logout' }
--- results: { controller => 'users', action => 'logout' }

===
--- path: /signup
--- params: { action => 'signup' }
--- request: { path => '/signup' }
--- results: { controller => 'users', action => 'signup' }
