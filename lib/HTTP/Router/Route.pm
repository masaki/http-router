package HTTP::Router::Route;

use Moose;
use Storable qw(dclone);

has 'path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => sub {
        my ($self, $path) = @_;

        # emulate named capture
        my @capture;
        my $re = $path || $self->path;
        $re =~ s/{(\w+)}/ push @capture, $1; '(.+)' /ge;

        $self->re(qr{^$re$});
        $self->capture(\@capture);
    },
);

has 'conditions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

has 'requirements' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

has 'defaults' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

has 're' => (
    is  => 'rw',
    isa => 'RegexpRef',
);

has 'capture' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub match {
    my ($self, $req) = @_;

    return unless blessed $req; # no request object
    return unless $self->_check_conditions($req);

    my $path;
    if ($req->can('path')) {
        $path = $req->path;
    }
    elsif (blessed $req->uri) {
        $path = $req->uri->path;
    }
    else {
        $path = $req->uri;
    }

    if ($self->path =~ m!^/!) {
        $path = "/$path" unless $path =~ m!^/!;
    }
    else {
        $path =~ s!^/+!!;
    }

    return unless $path =~ $self->re;

    # from HTTPx::Dispatcher
    my @start = @-;
    my @end   = @+;
    my $match = dclone($self->defaults);
    my $index = 1;
    for my $key ($self->capture) {
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

sub _check_conditions {
    my ($self, $req) = @_;

    return 1 unless my $method = $self->conditions->{method};

    $method = [ $method ] unless ref $method;
    my $expect = uc $req->method eq 'HEAD' ? 'GET' : uc $req->method;

    return scalar( grep { $expect eq uc $_ } @$method ) > 0;
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
