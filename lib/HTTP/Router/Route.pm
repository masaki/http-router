package HTTP::Router::Route;

use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use URI::Template::Restrict 0.03;
use HTTP::Router::Match;

has 'path' => (
    is         => 'rw',
    isa        => 'Str',
    metaclass  => 'String',
    lazy_build => 1,
    provides   => { append => 'append_path' },
);

has 'params' => (
    is         => 'rw',
    isa        => 'HashRef',
    metaclass  => 'Collection::Hash',
    lazy_build => 1,
    provides   => { set => 'add_params' },
);

has 'conditions' => (
    is         => 'rw',
    isa        => 'HashRef',
    metaclass  => 'Collection::Hash',
    lazy_build => 1,
    provides   => { set => 'add_conditions' },
);

has 'parts' => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub { $_[0]->path =~ tr!/!/! },
);

has 'templates' => (
    is         => 'rw',
    isa        => 'URI::Template::Restrict',
    lazy_build => 1,
    handles    => [qw'variables extract'],
);

sub _build_path       { '' }
sub _build_params     { {} }
sub _build_conditions { {} }

sub _build_templates { URI::Template::Restrict->new($_[0]->path) }

sub match {
    my ($self, $req) = @_;
    return unless blessed $req and $req->can('path');

    my $path = $req->path;
    defined $path or return;

    # path, captures
    my %vars;
    if ($self->variables) {
        my $size = $path =~ tr!/!/!;
        $size == $self->parts             or return; # FIXME: ignore parts
        %vars = $self->extract($path)     or return;
        $self->_is_valid_variables(\%vars) or return;
    }
    else {
        $path eq $self->path or return;
    }

    # conditions
    $self->_is_valid_request($req) or return;

    for my $key (keys %{ $self->params }) {
        next if exists $vars{$key};
        $vars{$key} = $self->params->{$key};
    }
    return HTTP::Router::Match->new(params => \%vars, route => $self);
}

sub _is_valid_variables {
    my ($self, $vars) = @_;

    for my $name (keys %$vars) {
        return 0 unless $self->_validate($vars->{$name}, $self->conditions->{$name});
    }

    return 1;
}

sub _is_valid_request {
    my ($self, $req) = @_;

    my $conditions = do {
        my %vars = map { $_ => 1 } $self->variables;
        [ grep { !$vars{$_} } keys %{ $self->conditions } ];
    };

    for my $name (@$conditions) {
        return 0 unless my $code = $req->can($name);

        my $value = $code->($req);
        if ($name eq 'method') { # HEAD equals to GET
            $value = 'GET' if $value eq 'HEAD';
        }

        return 0 unless $self->_validate($value, $self->conditions->{$name});
    }

    return 1;
}

sub _validate {
    my ($self, $input, $expected) = @_;
    # arguments
    return 0 unless defined $input;
    return 1 unless defined $expected;
    # validation
    return $input =~ $expected              if ref $expected eq 'Regexp';
    return grep { $input eq $_ } @$expected if ref $expected eq 'ARRAY';
    return $input eq $expected;
}

sub uri_for {
    my ($self, $args) = @_;

    for my $name (keys %{ $args || {} }) {
        return unless $self->_validate($args->{$name}, $self->conditions->{$name});
    }

    return $self->templates->process_to_string(%$args);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

=for stopwords params

=head1 NAME

HTTP::Router::Route

=head1 METHODS

=head2 match($req)

=head2 uri_for($captures?)

=head2 append_path($path)

=head2 add_params($params)

=head2 add_conditions($conditions)

=head2 extract($path)

=head1 PROPERTIES

=head2 path

=head2 params

=head2 conditions

=head2 templates

=heads parts

=head2 variables

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>

=cut
