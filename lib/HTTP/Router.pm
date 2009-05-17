package HTTP::Router;

use 5.008_001;
use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use Hash::AsObject;
use List::MoreUtils 'part';
use HTTP::Router::Route;

our $VERSION = '0.01';

has 'routes' => (
    is         => 'ro',
    isa        => 'ArrayRef',
    metaclass  => 'Collection::Array',
    lazy       => 1,
    builder    => '_build_routes',
    auto_deref => 1,
    provides   => {
        push  => 'add_route',
        clear => 'clear_routes',
    },
);

has 'use_inline_match' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0, # TODO: set to 1
    trigger => sub { $_[0]->clear_inline_matcher },
);

has 'inline_matcher' => (
    is         => 'rw',
    isa        => 'CodeRef',
    lazy_build => 1,
);

sub _build_routes { [] }

sub _build_inline_matcher {
    # TODO: not implemented yet
    sub {};
=comment
        my $path = $req->path;

        my ($path_routes, $capture_routes) = do {
            my $parts = $path =~ tr!/!/!;
            part { $_->templates->expansions } grep { $_->parts <= $parts } $self->routes;
        };

        # path
        for my $route (@$path_routes) {
            my $match = $route->match($req) or next;
            return $match; # return if found path route
        }

        # capture
        for my $route (@$capture_routes) {
            my $match = $route->match($req) or next;
            return $match;
        }
=cut
}

around 'add_route' => sub {
    my ($next, $self, $route, @args) = @_;

    unless (blessed $route) {
        $route = HTTP::Router::Route->new(path => $route, @args);
    }
    $self->clear_inline_matcher;

    $next->($self, $route);
};

sub reset {
    my $self = shift;
    $self->clear_routes;
    $self->clear_inline_matcher;
    $self;
}

sub match {
    my $self = shift;
    my $req  = blessed $_[0] ? $_[0] : Hash::AsObject->new(path => $_[0], %{ $_[1] || {} });

    if ($self->use_inline_match) {
        return $self->inline_matcher->($req);
    }
    else {
        for my $route ($self->routes) {
            my $match = $route->match($req) or next;
            return $match;
        }

        return;
    }
}

sub route_for {
    my $self = shift;

    if (my $match = $self->match(@_)) {
        return $match->route;
    }

    return;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

HTTP::Router - Yet Another Path Router for HTTP

=head1 SYNOPSIS

  use HTTP::Router;

  my $router = HTTP::Router->new;

  my $route = HTTP::Router::Route->new(
      path       => '/',
      conditions => { method => 'GET' },
      params     => { controller => 'Root', action => 'index' },
  );
  $router->add_route($route);
  # or
  $router->add_route('/' => (
      conditions => { method => 'GET' },
      params     => { controller => 'Root', action => 'index' },
  ));

  # GET /
  my $match = $router->match($req);
  $match->params;  # { controller => 'Root', action => 'index' }
  $match->uri_for; # '/'

=head1 DESCRIPTION

HTTP::Router provides a Merb-like way of constructing routing tables.

=head1 METHODS

=head2 new

=head2 add_route($route)

=head2 add_route($path, %args)

=head2 routes

=head2 reset

=head2 match($req)

=head2 route_for($req)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router::Declare>, L<HTTP::Router::Route>, L<HTTP::Router::Match>,

L<MojoX::Routes>, L<http://merbivore.com/>,
L<HTTPx::Dispatcher>, L<Path::Router>, L<Path::Dispatcher>

=cut
