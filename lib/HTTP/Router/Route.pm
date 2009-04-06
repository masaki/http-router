package HTTP::Router::Route;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use Hash::Merge 'merge';
use List::MoreUtils 'any';
use Scalar::Util 1.14 'blessed';
use URI::Template::Restrict;
use HTTP::Router::Match;

__PACKAGE__->mk_ro_accessors(qw'path parts templates params conditions');

sub variables { shift->templates->variables }

sub new {
    my $class = shift;
    my $args  = ref $_[0] ? $_[0] : { @_ };

    my @parts = split m!/! => $args->{path};
    $args->{parts}        = scalar @parts;
    $args->{templates}    = URI::Template::Restrict->new($args->{path});
    $args->{params}     ||= {};
    $args->{conditions} ||= {};

    return bless $args, $class;
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

    return HTTP::Router::Match->new({
        params   => merge(\%vars, $self->params),
        captures => \%vars,
        route    => $self,
    });
}

sub uri_for {
    my ($self, $captures) = @_;

    my $params = $captures || {};
    for my $name (keys %$params) {
        return unless $self->validate($params->{$name}, $self->conditions->{$name});
    }

    return $self->templates->process_to_string(%$params);
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
    return $input =~ $expected             if ref $expected eq 'Regexp';
    return any { $input eq $_ } @$expected if ref $expected eq 'ARRAY';
    return $input eq $expected;
}

1;

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
