package HTTP::Router::Builder;
use Moose;
use HTTP::Router::Builder::Connect;
use HTTP::Router::Builder::SingletonResource;
use HTTP::Router::Builder::Resources;

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
        HTTP::Router::Builder::SingletonResource->new;
    },
    handles => { 'build_resource' => 'build', }
);

has 'resources_builder' => (
    is      => 'rw',
    default => sub {
        HTTP::Router::Builder::Resources->new;
    },
    handles => { 'build_resources' => 'build', }
);

no Moose;

__PACKAGE__->meta->make_immutable;

1;
