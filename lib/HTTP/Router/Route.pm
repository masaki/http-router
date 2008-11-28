package HTTP::Router::Route;

use Moose;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(true);
use Storable qw(dclone);

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

has 'defaults' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

has 'conditions' => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[Str|ArrayRef|RegexpRef]',
    default   => sub { +{} },
    provides  => {
        empty => 'has_conditions',
        kv    => 'each_conditions',
    },
);

has 'requirements' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
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

__PACKAGE__->meta->make_immutable;

no Moose;

sub match {
    my ($self, $path, $conditions) = @_;

    if ($self->has_conditions) {
        for my $kv ($self->each_conditions) {
            my ($name, $expected) = @$kv;

            # condition missing
            return unless exists $conditions->{$name};

            my $condition = $conditions->{$name};
            if (ref $expected eq 'Regexp') {
                return unless $condition =~ $expected;
            }
            elsif (reftype $expected eq 'ARRAY') {
                return unless true { $condition eq $_ } @$expected;
            }
            else {
                return unless $condition eq $expected;
            }
        }
    }

    $path = "/$path" unless $path =~ m!^/!;
    return unless $path =~ $self->pattern;

    # from HTTPx::Dispatcher
    my @start = @-;
    my @end   = @+;
    my $match = dclone $self->defaults;
    my $index = 1;
    for my $key ($self->captures) {
        my $start = $start[$index];
        my $end   = $end[$index] - $start[$index];
        my $value = substr $path, $start, $end;

        # requirements - validation
        if (exists $self->requirements->{$key}) {
            return unless $value =~ $self->requirements->{$key};
        }

        $match->{$key} = $value;
        $index++;
    }

    return $match;
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

sub _uri_for_match {
    my ($self, $path, $key, $value) = @_;

    return $path if exists $self->defaults->{$key} and $self->defaults->{$key} eq $value;
    return $path if $path =~ s/{$key}/$value/;
    return;
}

1;

=head1 NAME

HTTP::Router::Route

=head1 METHODS

=head2 match($req)

=head2 uri_for($args)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>

=cut
