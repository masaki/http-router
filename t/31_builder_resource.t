use Test::Base -Base;
plan tests => 1 * blocks;

use HTTP::Router::Builder::SingletonResource;
use HTTP::Router::Route;
use HTTP::Router::Debug;

filters { params => ['yaml'], };

run {
    my $block        = shift;
    my $conditions   = $block->conditions || {};
    my $requirements = $block->requirements || {};

    my @actual
        = HTTP::Router::Builder::SingletonResource->new->build( $block->controller);
        #    HTTP::Router::Debug->show_table(@actual);
    my $expected_routes_num = 12;
    is @actual, $expected_routes_num;
};

__END__

=== /
--- controller: Root

