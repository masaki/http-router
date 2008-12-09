package HTTP::Router::Builder::Resource;
use Moose;
use String::CamelCase qw(camelize);
extends 'HTTP::Router::Builder::Base';

sub build {
    my ( $self, $controller, $opts ) = @_;
    my $routes = [];

    push @{$routes}, $self->_build_index_route($controller);
    push @{$routes}, $self->_build_create_route($controller);
    push @{$routes}, $self->_build_new_route($controller);
    push @{$routes}, $self->_build_edit_route($controller);
    push @{$routes}, $self->_build_show_route($controller);
    push @{$routes}, $self->_build_update_route($controller);
    push @{$routes}, $self->_build_destroy_route($controller);

    if ($opts->{collection}) {
        push @{$routes}, $self->_build_collection_route($controller, $opts->{collection});
    }
    
    if ($opts->{member}) {
        push @{$routes}, $self->_build_member_route($controller, $opts->{collection});
    }
    wantarray ? @{$routes} : $routes;
}

sub _build_collection_route {
    my ( $self, $controller, $collection ) = @_;
    foreach my $action ( keys %{$collection} ) {
        my $path = '/' . $controller . '/' . $action;
        my $args = {};
        $args->{controller} = camelize($controller);
        $args->{action}     = $action;
        $args->{conditions} = { method => [ $collection->{$action} ] };
        $self->build_route( $path => $args );
    }
}

sub _build_member_route {
    my ( $self, $controller, $member ) = @_;
    foreach my $action ( keys %{$member} ) {
        my $path = '/' . $controller . '/{id}/' . $action;
        my $args = {};
        $args->{controller} = camelize($controller);
        $args->{action}     = $action;
        $args->{conditions} = { method => [ $member->{$action} ] };
        $self->build_route( $path => $args );
    }
}

sub _build_index_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller;
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'index';
    $args->{conditions} = { method => ['GET'] };
    $self->build_route( $path => $args );
}

sub _build_create_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller;
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'create';
    $args->{conditions} = { method => ['POST'] };
    $self->build_route( $path => $args );
}

sub _build_new_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller . '/new';
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'new';
    $args->{conditions} = { method => ['POST'] };
    $self->build_route( $path => $args );
}

sub _build_edit_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller . '/{id}/edit';
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'edit';
    $args->{conditions} = { method => ['GET'] };
    $self->build_route( $path => $args );
}

sub _build_show_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller . '/{id}';
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'show';
    $args->{conditions} = { method => ['GET'] };
    $self->build_route( $path => $args );
}

sub _build_update_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller . '/{id}';
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'update';
    $args->{conditions} = { method => ['PUT'] };
    $self->build_route( $path => $args );
}

sub _build_destroy_route {
    my ( $self, $controller ) = @_;
    my $path = '/' . $controller . '/{id}';
    my $args = {};
    $args->{controller} = camelize($controller);
    $args->{action}     = 'destroy';
    $args->{conditions} = { method => ['DELETE'] };
    $self->build_route( $path => $args );
}

__PACKAGE__->meta->make_immutable;

1;
