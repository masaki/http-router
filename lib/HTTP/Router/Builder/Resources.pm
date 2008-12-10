package HTTP::Router::Builder::Resources;
use Moose;
use String::CamelCase qw(camelize);
use Carp ();
extends 'HTTP::Router::Builder::Resource';

no Moose;

sub build {
    my ( $self, $controller, $opts ) = @_;
    my $routes = [];

    push @{$routes}, @{ $self->build_common_routes( $controller, $opts ) };
    push @{$routes}, @{ $self->_build_index_route($controller) };

    if ( exists $opts->{collection} ) {
        push @{$routes},
            @{
            $self->_build_collection_route(
                $controller, $opts->{collection}
            )
            };
    }

    if ( exists $opts->{member} ) {
        push @{$routes},
            @{ $self->_build_member_route( $controller, $opts->{member} ) };
    }

    wantarray ? @{$routes} : $routes;
}

sub _build_index_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller;
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'index';
    $args->{conditions} = { method => ['GET'] };
    $self->build_routes( $path => $args );
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

__PACKAGE__->meta->make_immutable;

1;
