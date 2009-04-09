package HTTP::Router::Match;

use Any::Moose;

has 'params' => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { +{} },
);

has 'route' => (
    is       => 'rw',
    isa      => 'HTTP::Router::Route',
    handles  => ['uri_for'],
    required => 1,
);

no Any::Moose;

__PACKAGE__->meta->make_immutable;

=head1 NAME

HTTP::Router::Match

=head1 METHODS

=head2 uri_for($args?)

=head1 PROPERTIES

=head2 params

=head2 route

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<HTTP::Router::Route>

=cut
