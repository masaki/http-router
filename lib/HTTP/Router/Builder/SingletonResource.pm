package HTTP::Router::Builder::SingletonResource;
use Moose;
extends 'HTTP::Router::Builder::Resource';

sub build {
    my ( $self, $controller, $opts ) = @_;
    $self->build_common_routes($controller, $opts);
}

__PACKAGE__->meta->make_immutable;

1;
