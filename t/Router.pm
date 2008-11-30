package t::Router;

use Test::Base -Base;
use HTTP::Router;

our @EXPORT = qw(build_router);

sub build_router () {
    my $routes = eval { require 't/routes.pl' };
    my $router = HTTP::Router->new;
    $router->connect(@$_) for @$routes;
    $router;
}

1;
