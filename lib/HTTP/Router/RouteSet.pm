package HTTP::Router::RouteSet;

use Mouse;

has 'routes' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    default    => sub { [] },
    lazy       => 1,
    auto_deref => 1,
);

has 'named_routes' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
    lazy    => 1,
);

sub add_route {
    my ($self, $route) = @_;
    push @{ $self->routes }, $route;
}

sub add_named_route {
    my ($self, $name, $route) = @_;
    $self->named_routes->{$name} = $route;
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;

=head1 NAME

HTTP::Router::Routes

=head1 METHODS

=head2 all

=head2 push($route)

=head1 PROPERTIES

=head2 routes

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<HTTP::Router::Route>

=cut
