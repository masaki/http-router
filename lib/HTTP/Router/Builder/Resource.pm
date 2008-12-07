package HTTP::Router::Builder::Resource;
use Moose;
use String::CamelCase qw(camelize);
extends 'HTTP::Router::Builder::Base';

sub build {
    my ( $self, $controller ) = @_;
    my $routes = [];
    push @{$routes}, $self->_build_index_route($controller);
    push @{$routes}, $self->_build_create_route($controller);
    push @{$routes}, $self->_build_new_route($controller);
    push @{$routes}, $self->_build_edit_route($controller);
    push @{$routes}, $self->_build_show_route($controller);
    push @{$routes}, $self->_build_update_route($controller);
    push @{$routes}, $self->_build_destroy_route($controller);
    wantarray ? @{$routes} : $routes;
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
