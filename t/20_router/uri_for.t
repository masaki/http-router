use Test::Base;
use HTTP::Router;

plan tests => 1 * blocks;

filters {
    map { $_ => ['eval'] } qw(args)
};

my $r = HTTP::Router->new();
$r->add_route('/',          params => { action => 'jackson' });
$r->add_route('/bar',       params => { action => 'path' });
$r->add_route('/{year}',    params => { action => 'by_year' },
    conditions => { year => qr/^\d{4}$/ }
);
$r->add_route('/admin',     params => { action => 'capture', user_id => 'bill' });
$r->add_route('/{user_id}', params => { action => 'capture' });

run {
    my $block = shift;
    my $name  = $block->name;
    is $r->uri_for(%{$block->args}) => $block->uri, "uri_for ($name)";
};

__END__
=== basic match
--- args: { action => 'jackson' }
--- uri : /

=== non-primary match
--- args: { action => 'path' }
--- uri : /bar

=== conditional match, valid arguments
--- args: { action => 'by_year', year => 2010 }
--- uri : /2010

=== conditional match, invalid arguments - undef
--- args: { action => 'by_year', year => 'rat' }

=== parameter match
--- args: { action => 'capture', user_id => 'bill' }
--- uri : /admin

=== capture match
--- args: { action => 'capture', user_id => 'joe' }
--- uri : /joe
