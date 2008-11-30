use Test::Base;
use HTTP::Router;

plan tests => 1 * blocks;

my $routes = eval { require 't/routes.pl' };
my $router = HTTP::Router->new;
$router->connect(@$_) for @$routes;

filters {
    conditions => ['eval'],
    expected   => ['yaml'],
};

run {
    my $block = shift;

    my $match = $router->match($block->path, $block->conditions);
    is_deeply $match, $block->expected;
};

__END__
===
--- path: /
--- expected
controller: Root
action: index

===
--- path: /
--- conditions: { method => 'GET' }
--- expected
controller: Root
action: index

===
--- path: /account/login
--- conditions: { method => 'GET' }
--- expected
controller: Account
action: login

===
--- path: /account/login
--- conditions: { method => 'POST' }
--- expected
controller: Account
action: login

===
--- path: /articles/14
--- conditions: { method => 'GET' }
--- expected
controller: Article
action: show
article_id: 14

===
--- path: /articles/15
--- conditions: { method => 'PUT' }
--- expected
controller: Article
action: update
article_id: 15

===
--- path: /articles/16
--- conditions: { method => 'DELETE' }
--- expected
controller: Article
action: destroy
article_id: 16
