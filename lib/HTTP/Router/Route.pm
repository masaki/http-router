package HTTP::Router::Route;

use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use Clone ();
use URI::Template::Restrict 0.03;
use HTTP::Router::Match;

has 'path' => (
    is        => 'rw',
    isa       => 'Str',
    metaclass => 'String',
    default   => '',
    trigger   => sub { goto &freeze },
    provides  => {
        append => 'append_path',
    },
);

has 'params' => (
    is        => 'rw',
    isa       => 'HashRef',
    metaclass => 'Collection::Hash',
    default   => sub { +{} },
    provides  => {
        set => 'add_params',
    },
);

has 'conditions' => (
    is        => 'rw',
    isa       => 'HashRef',
    metaclass => 'Collection::Hash',
    default   => sub { +{} },
    provides  => {
        set => 'add_conditions',
    },
);

has 'parts' => (
    is  => 'rw',
    isa => 'Int',
);

has 'templates' => (
    is      => 'rw',
    isa     => 'URI::Template::Restrict',
    handles => ['variables'],
);

has 'frozen' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

after 'freeze' => sub {
    $_[0]->frozen(1);
};

no Any::Moose;

sub freeze {
    my $self = shift;

    my $path = $self->path;
    my @parts = split m!/! => $path;
    $self->parts(scalar @parts);
    $self->templates(URI::Template::Restrict->new($path));

    return $self;
}

sub clone {
    my $self = shift;
    return $self->frozen ? undef : Clone::clone($self);
}

sub match {
    my ($self, $req) = @_;
    return unless blessed $req and $req->can('path');

    my $path = $req->path;
    return unless defined $path;

    # part size
    my $size = scalar @{[ split m!/! => $path ]};
    return unless $size == $self->parts;

    # path, captures
    my %vars = $self->templates->extract($path);
    if (%vars) {
        return unless $self->check_variable_conditions(\%vars);
    }
    else {
        return unless $path eq $self->path;
    }

    # conditions
    return unless $self->check_request_conditions($req);

    for my $key (keys %{ $self->params }) {
        next if exists $vars{$key};
        $vars{$key} = $self->params->{$key};
    }
    return HTTP::Router::Match->new(params => \%vars, route => $self);
}

sub uri_for {
    my ($self, $args) = @_;

    for my $name (keys %{ $args || {} }) {
        return unless $self->validate($args->{$name}, $self->conditions->{$name});
    }

    return $self->templates->process_to_string(%$args);
}

sub check_variable_conditions {
    my ($self, $vars) = @_;

    for my $name (keys %$vars) {
        return 0 unless $self->validate($vars->{$name}, $self->conditions->{$name});
    }

    return 1;
}

sub check_request_conditions {
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

        return 0 unless $self->validate($value, $self->conditions->{$name});
    }

    return 1;
}

sub validate {
    my ($self, $input, $expected) = @_;
    # arguments
    return 0 unless defined $input;
    return 1 unless defined $expected;
    # validation
    return $input =~ $expected              if ref $expected eq 'Regexp';
    return grep { $input eq $_ } @$expected if ref $expected eq 'ARRAY';
    return $input eq $expected;
}

__PACKAGE__->meta->make_immutable;

=for stopwords params

=head1 NAME

HTTP::Router::Route

=head1 METHODS

=head2 match($req)

=head2 uri_for($captures?)

=head1 PROPERTIES

=head2 path

=head2 params

=head2 conditions

=head2 variables

=head2 templates

=head1 INTERNALS

=head2 check_variable_conditions

=head2 check_request_conditions

=head2 validate

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>

=cut
