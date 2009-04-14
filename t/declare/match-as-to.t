use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router::Declare;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(params conditions request results) };

my $router = router {
    while (my $block = next_block) {
        match $block->path => as $block->conditions => to $block->params;
    }
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
--- path: /
--- params: { name => 'root' }
--- request: { path => '/' }
--- results: { name => 'root' }

===
--- path: /home
--- conditions: { method => 'GET' }
--- params: { name => 'home' }
--- request: { path => '/home', method => 'GET' }
--- results: { name => 'home' }

===
--- path: /archives/{year}
--- conditions: { year => qr/^\d{4}$/ }
--- params: { name => 'archives' }
--- request: { path => '/archives/2008' }
--- results: { name => 'archives', year => 2008 }

===
--- path: /users/{user_id}
--- conditions: { user_id => qr/^\d+$/, method => 'GET' }
--- params: { name => 'users' }
--- request: { path => '/users/100', method => 'GET' }
--- results: { name => 'users', user_id => 100 }
