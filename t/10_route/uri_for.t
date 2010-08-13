use Test::Base;
use HTTP::Router::Route;

plan tests => 1 * blocks;

filters {
    map { $_ => ['eval'] } qw(conditions args params)
};

run {
    my $block = shift;
    my $name  = $block->name;
    my $route = HTTP::Router::Route->new(
        path       => $block->path,
        params     => $block->params || {},
        conditions => $block->conditions || {},
    );

    is $route->uri_for($block->args) => $block->uri, "uri_for ($name)";
};

__END__
=== path
--- path: /
--- uri : /

=== path with args
--- path: /
--- uri : /
--- args: { year => 2008 }

=== path with params
--- path  : /
--- uri   : /
--- params: { controller => 'Foo', action => 'bar' }
--- args  : { controller => 'Foo', action => 'bar' }

=== captures
--- path: /archives/{year}/{month}
--- uri : /archives/2008/Dec
--- args: { year => 2008, month => 'Dec' }

=== captures and conditions
--- path: /archives/{year}/{month}
--- conditions: { year => qr/^\d{4}$/, month => qr/^\d{1,2}$/ }
--- uri : /archives/2008/12
--- args: { year => 2008, month => 12 }

=== invalid conditions - undef
--- path: /archives/{year}/{month}
--- conditions: { year => qr/^\d{4}$/, month => qr/^\d{1,2}$/ }
--- args: { year => '08', month => 'Dec' }

=== incomplete params - undef
--- path  : /
--- params: { controller => 'Foo', action => 'bar' }
--- args  : { controller => 'Foo' }

=== invalid params - undef
--- path  : /
--- params: { action => 'foo' }
--- args  : { action => 'bar' }
