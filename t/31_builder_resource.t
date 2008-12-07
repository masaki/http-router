use Test::Base -Base;
plan tests => 1 * blocks;

use HTTP::Router::Builder::Resource;
use HTTP::Router::Route;

filters { params => ['yaml'], };

run {
    my $block        = shift;
    my $conditions   = $block->conditions || {};
    my $requirements = $block->requirements || {};

    my @actual
        = HTTP::Router::Builder::Resource->new->build( $block->controller );
    my $expected_routes_num = 7;
    is @actual, $expected_routes_num;
};

__END__

=== /
--- controller: Root

