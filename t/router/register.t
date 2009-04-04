use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(request results) };

my $router = HTTP::Router->define(sub {
    $_->match('/{controller}/{action}/{id}.{format}')->register;
    $_->match('/{controller}/{action}/{id}')->register;
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
--- request: { path => '/foo/bar/baz' }
--- results: { controller => 'foo', action => 'bar', id => 'baz' }

===
--- request: { path => '/foo/bar/baz.html' }
--- results: { controller => 'foo', action => 'bar', id => 'baz', format => 'html' }
