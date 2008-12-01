package HTTP::Router::Match;

use Moose;

has 'path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'params' => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
    default  => sub { +{} },
);

has 'route' => (
    is       => 'rw',
    isa      => 'HTTP::Router::Route',
    required => 1,
);

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 NAME

HTTP::Router::Match

=head1 METHODS

=head2 path

=head2 params

=head2 route

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>

=cut
