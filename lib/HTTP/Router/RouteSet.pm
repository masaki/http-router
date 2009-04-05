package HTTP::Router::RouteSet;

use strict;
use warnings;
use base 'Class::Accessor::Fast';

__PACKAGE__->mk_ro_accessors(qw'routes named_routes');

sub new {
    return bless { routes => [], named_routes => {} }, shift;
}

sub add_route {
    my ($self, $route) = @_;
    push @{ $self->routes }, $route;
}

sub add_named_route {
    my ($self, $name, $route) = @_;
    $self->named_routes->{$name} = $route;
}

1;

=head1 NAME

HTTP::Router::RouteSet

=head1 METHODS

=head2 add_route($route)

=head2 add_named_route($name, $route)

=head1 PROPERTIES

=head2 routes

=head2 named_routes

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<HTTP::Router::Route>

=cut
