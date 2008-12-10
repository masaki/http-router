package HTTP::Router::Plugin;
use Moose;
use Sub::Install;
use Carp ();

no Moose;

sub setup {
    my $self        = shift;
    my $builder_sub = $self->make_builder_sub;
    $self->_install($builder_sub);
}

sub make_builder_sub {
    Carp::croak 'sub class must implement this method !!!';
}

sub _install {
    my ( $self, $builder_sub ) = @_;
    Sub::Install::install_sub(
        {   code => $builder_sub,
            into => 'HTTP::Router',
            as   => $self->plugin_name,
        }
    );
}

sub plugin_name {
    my $self  = shift;
    my $class = ref $self;
    my $plugin;
    if ( $class =~ /^HTTP::Router::Plugin::(.+)$/ ) {
        $plugin = $1;
    }
    return lc $plugin;
}

__PACKAGE__->meta->make_immutable;

1;

=for stopwords params

=head1 NAME

HTTP::Router::Plugin

=head1 METHODS


=head1 PROPERTIES


=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO


=cut


