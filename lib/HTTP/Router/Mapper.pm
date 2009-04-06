package HTTP::Router::Mapper;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use Hash::Merge qw(merge);
use HTTP::Router::Route;
use HTTP::Router::RouteSet;
use HTTP::Router::Resources;

__PACKAGE__->mk_ro_accessors('routeset');
__PACKAGE__->mk_accessors(qw'path params conditions route');

sub new {
    my $class = shift;
    my $args  = ref $_[0] ? $_[0] : { @_ };

    $args->{path}       ||= '';
    $args->{params}     ||= {};
    $args->{conditions} ||= {};

    return bless $args, ref $class || $class;
}

sub freeze {
    my $self = shift;

    my $route = HTTP::Router::Route->new({
        path       => $self->path,
        params     => $self->params,
        conditions => $self->conditions,
    });

    $self->routeset->add_route($route);
    $self->route($route);

    return $self;
}

sub clone {
    my ($self, %params) = @_;
    return $self->new(%params, routeset => $self->routeset);
}

sub match {
    my $self = shift;
    return $self if $self->route;

    my $block = ref $_[-1] eq 'CODE' ? pop : undef;
    my ($path, $conditions) = @_;

    my $mapper = $self->clone(
        path       => $self->path . $path,
        conditions => merge($conditions || {}, $self->conditions),
        params     => $self->params,
    );
    if ($block) {
        local $_ = $mapper;
        $block->($_);
    }

    return $mapper;
}

sub to {
    my $self = shift;
    return $self if $self->route;

    my $block = ref $_[-1] eq 'CODE' ? pop : undef;
    my $params = shift || {};

    my $mapper = $self->clone(
        path       => $self->path,
        conditions => $self->conditions,
        params     => merge($params, $self->params),
    );
    if ($block) {
        local $_ = $mapper;
        $block->($_);
    }
    else {
        $mapper->freeze;
    }

    return $mapper;
}

# alias 'with' and 'register' => 'to'
{
    no warnings 'once';
    *with     = \&to;
    *register = \&to;
}

#sub namespace {}
#sub name {}

1;

=for stopwords params routeset

=head1 NAME

HTTP::Router::Mapper

=head1 SYNOPSIS

  my $router = HTTP::Router->define(sub {
      $_->match('/index.{format}')
          ->to({ controller => 'Root', action => 'index' });

      $_->match('/archives/{year}', { year => qr/\d{4}/ })
          ->to({ controller => 'Archive', action => 'by_month' });

      $_->match('/account/login', { method => ['GET', 'POST'] })
          ->to({ controller => 'Account', action => 'login' });

      $_->with({ controller => 'Account' }, sub {
          $_->match('/account/signup')->to({ action => 'signup' });
          $_->match('/account/logout')->to({ action => 'logout' });
      });

      $_->match('/')->register;
  });

=head1 METHODS

=head2 match($path, $conditions?, $block?)

=head2 to($params?, $block?)

=head2 with($params?, $block?)

=head2 register

=head1 PROPERTIES

=head2 routeset

=head2 route

=head2 path

=head2 conditions

=head2 params

=head1 INTERNALS

=head2 freeze

=head2 clone

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<HTTP::Router::Route>

=cut
