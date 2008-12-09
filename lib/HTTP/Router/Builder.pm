package HTTP::Router::Builder;
use Moose;
use HTTP::Router::Builder::Connect;
use HTTP::Router::Builder::Resource;

has 'connect_builder' => (
    is      => 'rw',
    default => sub {
        HTTP::Router::Builder::Connect->new;
    },
    handles => { 'build_connect' => 'build', }
);

has 'resource_builder' => (
    is      => 'rw',
    default => sub {
        HTTP::Router::Builder::Resource->new;
    },
    handles => { 'build_resource' => 'build', }
);

no Moose;

__PACKAGE__->meta->make_immutable;

1;
