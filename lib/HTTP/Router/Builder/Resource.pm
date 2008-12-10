package HTTP::Router::Builder::Resource;
use Moose;
use String::CamelCase qw(camelize);
extends 'HTTP::Router::Builder::Base';

no Moose;

our $ROUTING_TABLE = [
    {   path => sub { my $controller = shift; '/' . $controller; },
        action     => 'create',
        conditions => { method => ['POST'] },
    },
    {   path => sub { my $controller = shift; '/' . $controller . '/new'; },
        action     => 'new',
        conditions => { method => ['POST'] },
    },
    {   path =>
            sub { my $controller = shift; '/' . $controller . '/{id}/edit'; },
        action     => 'edit',
        conditions => { method => ['GET'] },
    },
    {   path => sub { my $controller = shift; '/' . $controller . '/{id}'; },
        action     => 'show',
        conditions => { method => ['GET'] },
    },
    {   path => sub { my $controller = shift; '/' . $controller . '/{id}'; },
        action     => 'update',
        conditions => { method => ['PUT'] },
    },
    {   path => sub { my $controller = shift; '/' . $controller . '/{id}'; },
        action     => 'destroy',
        conditions => { method => ['DELETEJ'] },
    },
];

sub build_routes {
    my ( $self, $path, $args ) = @_;
    my $routes = [];
    push @{$routes}, $self->build_route_with_format( $path, => $args );
    push @{$routes}, $self->build_route( $path => $args );
    $routes;
}

sub build_common_routes {
    my ( $self, $controller, $opts ) = @_;

    my $routes = [];
    foreach my $routing ( @{$ROUTING_TABLE} ) {
        my $path = $routing->{path}->($controller);
        my $args = {};
        $args->{controller} = camelize($controller);
        $args->{action}     = $routing->{action};
        $args->{conditions} = $routing->{conditions};

        push @{$routes}, @{ $self->build_routes( $path => $args ) };
    }

    wantarray ? @{$routes} : $routes;
}

__PACKAGE__->meta->make_immutable;

1;
