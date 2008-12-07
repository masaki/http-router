package HTTP::Router::Builder::Connect;
use Moose;
extends 'HTTP::Router::Builder::Base';

sub build {
    my ( $self, $path, $args ) = @_;
    $self->build_route( $path => $args );
}

__PACKAGE__->meta->make_immutable;

1;
