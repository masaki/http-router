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
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[ Str | RegexpRef | ArrayRef ]',
    default   => sub { +{} },
    provides  => {
        get  => 'condition',
        keys => 'condition_names',
    },
);

has 'requirements' => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[ Str | RegexpRef | ArrayRef ]',
    default   => sub { +{} },
    provides  => {
        get    => 'requirement',
        exists => 'has_requirement',
    },
);

sub slashes {
    return scalar @{[ shift->path->as_string =~ m!/!g ]};
}

sub match {
    my ($self, $path, $conditions) = @_;

    # check path
    return unless $path eq $self->path->as_string;
    # check conditions
    return unless $self->_check_conditions($conditions);

    return $self->_build_match($path, dclone $self->params);
}

sub match_with_expansions {
    my ($self, $path, $conditions) = @_;

    # check path
    my %captures = $self->path->deparse($path);
    return unless all { defined } values %captures;

    # check requirements
    my $params = dclone $self->params;
    while (my ($key, $value) = each %captures) {
        if ($self->has_requirement($key)) {
            return unless $self->_validate($value, $self->requirement($key));
        }
        $params->{$key} = $value;
    }

    # check conditions
    return unless $self->_check_conditions($conditions);

    return $self->_build_match($path, $params);
}

sub uri_for {
    my ($self, $args) = @_;
    return $self->path->process_to_string($args || {});
}

sub _build_match {
    my ($self, $path, $params) = @_;

    return HTTP::Router::Match->new(
        path   => $path,
        params => $params,
        route  => $self,
    );
}

sub _check_conditions {
    my ($self, $conditions) = @_;

    return 1 unless defined $conditions;

    # check conditions
    for my $name ($self->condition_names) {
        my $input = $conditions->{$name};
        return unless defined $input; # missing
        return unless $self->_validate($input, $self->condition($name));
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
