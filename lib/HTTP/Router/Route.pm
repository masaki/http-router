package HTTP::Router::Route;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(all true);
use Storable qw(dclone);
use URI::Template 0.13;
use HTTP::Router::Match;

class_type 'URI::Template';

coerce 'URI::Template' => from 'Str' => via { URI::Template->new($_) };

has 'path' => (
    is       => 'rw',
    isa      => 'URI::Template',
    required => 1,
    coerce   => 1,
);

has 'params' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

has 'conditions' => (
    is      => 'rw',
    isa     => 'HashRef[ Str | RegexpRef | ArrayRef ]',
    default => sub { +{} },
);

has 'requirements' => (
    is      => 'rw',
    isa     => 'HashRef[ Str | RegexpRef | ArrayRef ]',
    default => sub { +{} },
);

sub slashes {
    return scalar @{[ shift->path->as_string =~ m!/!g ]};
}

sub match {
    my ($self, $path, $conditions) = @_;

    # check slashes
    return unless $self->_check_slashes($path);
    # check path
    return unless $path eq $self->path->as_string;
    # check conditions
    return unless $self->_check_conditions($conditions);

    return $self->_build_match($path, dclone $self->params);
}

sub match_with_expansions {
    my ($self, $path, $conditions) = @_;

    # check slashes
    return unless $self->_check_slashes($path);
    # check path
    my %captures = $self->path->deparse($path);
    return unless all { defined } values %captures;
    # check requirements
    return unless $self->_check_requirements(\%captures);
    # check conditions
    return unless $self->_check_conditions($conditions);

    my $params = dclone $self->params;
    $params = { %$params, %captures };

    return $self->_build_match($path, $params);
}

sub uri_for {
    my ($self, $args) = @_;

    my $params = $args || {};

    if ($self->path->variables > 0) {
        return unless $self->_check_requirements($params);
    }

    return $self->path->process_to_string(%$params);
}

sub _build_match {
    my ($self, $path, $params) = @_;

    return HTTP::Router::Match->new(
        path   => $path,
        params => $params,
        route  => $self,
    );
}

sub _check_slashes {
    my ($self, $path) = @_;
    return scalar @{[ $path =~ m!/!g ]} == $self->slashes;
}

sub _check_requirements {
    my ($self, $args) = @_;

    # not exists
    return 1 unless keys %{ $self->requirements } > 0;
    # not supplied
    return unless defined $args and keys %$args > 0;

    # check
    while (my ($key, $value) = each %$args) {
        next unless exists $self->requirements->{$key};
        return unless $self->_validate($value, $self->requirements->{$key});
    }

    return 1;
}

sub _check_conditions {
    my ($self, $args) = @_;

    # not exists
    return 1 unless my @keys = keys %{ $self->conditions };
    # not supplied
    return unless defined $args and keys %$args > 0;

    # check
    for my $key (@keys) {
        return unless exists $args->{$key};
        return unless $self->_validate($args->{$key}, $self->conditions->{$key});
    }

    return 1;
}

sub _validate {
    my ($self, $input, $expected) = @_;

    return $input =~ $expected              if ref $expected eq 'Regexp';
    return true { $input eq $_ } @$expected if ref $expected eq 'ARRAY';
    return $input eq $expected;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=for stopwords params

=head1 NAME

HTTP::Router::Route

=head1 METHODS

=head2 match($path, $conditions)

=head2 match_with_expansions($path, $conditions)

=head2 uri_for($args)

=head1 PROPERTIES

=head2 path

=head2 slashes

=head2 params

=head2 conditions

=head2 requirements

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>

=cut
