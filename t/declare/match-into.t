use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router::Declare;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(params conditions request results) };

my $router = router {
    match '/account', { method => 'GET' } => into {
        while (my $block = next_block) {
            match $block->path, $block->conditions => to $block->params;
        }
    };
};

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
--- params: { name => 'login' }
--- request: { path => '/account/login', method => 'GET' }
--- results: { name => 'login' }

===
--- path: /logout
--- params: { name => 'logout' }
--- request: { path => '/account/logout', method => 'GET' }
--- results: { name => 'logout' }
