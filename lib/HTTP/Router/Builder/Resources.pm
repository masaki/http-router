package HTTP::Router::Builder::Resources;
use Moose;
use Carp ();
extends 'HTTP::Router::Builder::Base';

sub build {
    Carp::croak 'Implement me';
}

sub _build_index_route {
    'Implement me!';
}

sub _build_collection_route {
    my ( $self, $controller, $collection ) = @_;
    my $routes = [];
    foreach my $action ( keys %{$collection} ) {
        my $path = '/' . $controller . '/' . $action;
        my $args = {};
        $args->{controller} = camelize($controller);
        $args->{action}     = $action;
        $args->{conditions} = { method => [ $collection->{$action} ] };
        push @{$routes}, @{ $self->build_routes( $path => $args ) };
    }
    $routes;
}

sub _build_member_route {
    my ( $self, $controller, $member ) = @_;
    my $routes = [];
    foreach my $action ( keys %{$member} ) {
        my $path = '/' . $controller . '/{id}/' . $action;
        my $args = {};
        $args->{controller} = camelize($controller);
        $args->{action}     = $action;
        $args->{conditions} = { method => [ $member->{$action} ] };
        push @{$routes}, @{ $self->build_routes( $path => $args ) };
    }
    $routes;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
