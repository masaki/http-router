package HTTP::Router::Plugin::Resource;
use Moose;
use HTTP::Router::Builder;
extends 'HTTP::Router::Plugin';

no Moose;

sub make_builder_sub {
    my $builder_sub = sub {
        my ( $self, $controller, $args ) = @_;

        my @routes = HTTP::Router::Builder->new->build_resource( $controller,
            $args );
        $self->add_route($_) for @routes;
    };
    $builder_sub;
}

__PACKAGE__->meta->make_immutable;

1;

=for stopwords params

=head1 NAME

HTTP::Router::Plugin::Resource

=head1 METHODS


=head1 PROPERTIES


=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO


=cut
