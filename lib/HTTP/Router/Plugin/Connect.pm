package HTTP::Router::Plugin::Connect;
use Moose;
use HTTP::Router::Builder;
extends 'HTTP::Router::Plugin';

sub make_builder_sub {
    my $builder_sub = sub {
        my ( $self, $path, $args ) = @_;
        my $route = HTTP::Router::Builder->new->build_connect( $path, $args );
        $self->add_route($route);
    };
    $builder_sub;
}

__PACKAGE__->meta->make_immutable;

1;

=for stopwords params

=head1 NAME

HTTP::Router::Plugin::Connect

=head1 METHODS


=head1 PROPERTIES


=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO


=cut


