package HTTP::Router::Builder::Base;
use Moose;

sub build_route_with_format {
    my ( $self, $path, $args ) = @_;
    $args ||= {};
    my $conditions   = $args->{conditions}   || {};
    my $requirements = $args->{requirements} || {};

    return HTTP::Router::Route->new(
        path         => $path . "/{format}",
        params       => $args,
        conditions   => $conditions,
        requirements => $requirements,
    );
}

sub build_route {
    my ( $self, $path, $args ) = @_;

    $args ||= {};
    my $conditions   = delete $args->{conditions}   || {};
    my $requirements = delete $args->{requirements} || {};

    return HTTP::Router::Route->new(
        path         => $path,
        params       => $args,
        conditions   => $conditions,
        requirements => $requirements,
    );
}

__PACKAGE__->meta->make_immutable;

1;

