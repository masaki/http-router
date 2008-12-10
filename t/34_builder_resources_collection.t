use Test::Base -Base;
plan tests => 1 * blocks;

use HTTP::Router::Builder::Resources;
use HTTP::Router::Route;
use HTTP::Router::Debug;

filters { collection => ['eval'] };

run {
    my $block        = shift;
    my $conditions   = $block->conditions || {};
    my $requirements = $block->requirements || {};
    my @actual
        = HTTP::Router::Builder::Resources->new->build( $block->controller,
        { collection => $block->collection } );
    #HTTP::Router::Debug->show_table(@actual);
    my $expected_routes_num = 16;
    is @actual, $expected_routes_num;
};

__END__

=== /
--- controller: Root
--- collection: { sold => 'GET'}

