use Test::Base -Base;
plan tests => 1 * blocks;

use HTTP::Router::Builder::Connect;
use HTTP::Router::Route;

filters { params => ['yaml'], };

run {
    my $block        = shift;
    my $conditions   = $block->conditions || {};
    my $requirements = $block->requirements || {};

    my $expected = HTTP::Router::Route->new(
        path         => $block->path,
        params       => $block->params,
        conditions   => $conditions,
        requirements => $requirements,
    );
    my $actual
        = HTTP::Router::Builder::Connect->new->build( $block->path, $block->params );
    is_deeply $actual, $expected;
};

__END__

=== /
--- path: /
--- params
controller: Root
action: index


