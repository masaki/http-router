package HTTP::Router::Route;

use Moose;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(true);
use Storable qw(dclone);
use HTTP::Router::Match;

has 'path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub {
        my ($self, $path) = @_;

        # emulate named capture
        my @captures;
        (my $pattern = $path) =~ s!{(\w+)}!push @captures, $1; '([^/]+)'!ge;

        $self->pattern(qr{^$pattern$});
        $self->captures(\@captures);
    },
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

has 'pattern' => (
    is  => 'rw',
    isa => 'RegexpRef',
);

has 'captures' => (
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
);

sub match {
    my ($self, $path, $conditions) = @_;

    # check conditions
    for my $name ($self->condition_names) {
        my $input = $conditions->{$name};
        return unless defined $input; # missing
        return unless $self->_validate($input, $self->condition($name));
    }

    # check path
    $path = "/$path" unless $path =~ m!^/!;
    return unless $path =~ $self->pattern;

    # from HTTPx::Dispatcher
    my @start = @-;
    my @end   = @+;
    my $index = 1;

    my $params = dclone $self->params;
    for my $key ($self->captures) {
        my $start = $start[$index];
        my $end   = $end[$index] - $start[$index];
        my $value = substr $path, $start, $end;

        # check requirements
        if ($self->has_requirement($key)) {
            return unless $self->_validate($value, $self->requirement($key));
        }

        $params->{$key} = $value;
        $index++;
    }

    return $self->_build_match($path, $params);
}

sub uri_for {
    my ($self, $args) = @_;

    my $path = $self->path;
    while (my ($key, $value) = each %{ $args || {} }) {
         $path = $self->_uri_for_match($path, $key, $value);
         return unless defined $path;
    }

    return $path;
}

sub _validate {
    my ($self, $input, $expected) = @_;

    return $input =~ $expected              if ref $expected eq 'Regexp';
    return true { $input eq $_ } @$expected if ref $expected eq 'ARRAY';
    return $input eq $expected;
}

sub _build_match {
    my ($self, $path, $params) = @_;

    return HTTP::Router::Match->new(
        path   => $path,
        params => $params,
        route  => $self,
    );
}

sub _uri_for_match {
    my ($self, $path, $key, $value) = @_;

    return $path if exists $self->params->{$key} and $self->params->{$key} eq $value;
    return $path if $path =~ s/{$key}/$value/;
    return;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 NAME

HTTP::Router::Route

=head1 METHODS

=head2 match($path, $conditions)

=head2 uri_for($args)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>

=cut
