package HTTP::Router;

use 5.008_001;
use strict;
use warnings;
use base 'Class::Accessor::Fast';
use Hash::AsObject;
use List::MoreUtils 'part';
use Scalar::Util 'blessed';
use HTTP::Router::Route;

our $VERSION = '0.03';

__PACKAGE__->mk_accessors(qw'code');

sub new {
    my $class = shift;
    return bless { routes => [], code => undef }, $class;
}

sub routes {
    my $self = shift;
    @{ $self->{routes} };
}

sub add_route {
    my ($self, $route, @args) = @_;

    unless (blessed $route) {
        $route = HTTP::Router::Route->new(path => $route, @args);
    }

    $self->thaw;
    push @{ $self->{routes} }, $route;
}

sub clear_routes {
    my $self = shift;
    $self->{routes} = [];
}

sub _build_code {
    my $self = shift;

    my ($path_routes, $capture_routes) =
        part { scalar $_->templates->expansions > 0 } $self->routes;

    return sub {
        my $req   = shift;
        my $parts = $req->path =~ tr!/!/!;

        # path
        for my $route (grep { $_->parts == $parts } @$path_routes) {
            my $match = $route->match($req) or next;
            return $match; # return if found path route
        }

        # capture
        for my $route (grep { $_->parts <= $parts } @$capture_routes) {
            my $match = $route->match($req) or next;
            return $match;
        }

        return;
    };
}

sub freeze {
    my $self = shift;
    $self->code( $self->_build_code );
    $self;
}

sub thaw {
    my $self = shift;
    $self->code(undef);
    $self;
}

sub reset {
    my $self = shift;
    $self->thaw;
    $self->clear_routes;
    $self;
}

sub match {
    my $self = shift;
    my $req  = blessed $_[0] ? $_[0] : Hash::AsObject->new(path => $_[0], %{ $_[1] || {} });

    if ($self->code) {
        return $self->code->($req);
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

1;

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

HTTP::Router provides a way of constructing routing tables.

If you are interested in a Merb-like constructing way,
please check L<HTTP::Router::Declare>.

=head1 METHODS

=head2 new

Returns a HTTP::Router object.

=head2 add_route($route)

=head2 add_route($path, %args)

Adds a new route.
You can specify L<HTTP::Router::Route> object,
or path string and options pair.

example:

  my $route = HTTP::Router::Route->new(
      path       => '/',
      conditions => { method => 'GET' },
      params     => { controller => 'Root', action => 'index' },
  );

  $router->add_route($route);

equals to:

  $router->add_route('/' => (
      conditions => { method => 'GET' },
      params     => { controller => 'Root', action => 'index' },
  ));

=head2 routes

Returns registered routes.

=head2 reset

Clears registered routes.

=head2 match($req)

Returns a L<HTTP::Router::Match> object that matches a given request.
If no routes match, it returns C<undef>.

=head2 route_for($req)

Returns a L<HTTP::Router::Route> object that matches a given request.
If no routes match, it returns C<undef>.

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
