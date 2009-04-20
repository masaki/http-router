package HTTP::Router;

use 5.008_001;
use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use Scalar::Util 1.14;
use HTTP::Router::Route;

our $VERSION = '0.01';

has 'routes' => (
    is         => 'ro',
    isa        => 'ArrayRef',
    metaclass  => 'Collection::Array',
    lazy       => 1,
    default    => sub { [] },
    auto_deref => 1,
    provides   => {
        push  => 'add_raw_route',
        clear => 'clear_routes',
    },
);

has 'named_routes' => (
    is         => 'ro',
    isa        => 'HashRef',
    metaclass  => 'Collection::Hash',
    lazy       => 1,
    default    => sub { +{} },
    auto_deref => 1,
    provides   => {
        set   => 'add_named_route',
        clear => 'clear_named_routes',
    },
);

no Any::Moose;

sub add_route {
    my ($self, $thing, %args) = @_;
    $thing = HTTP::Router::Route->new(path => $thing, %args)
        unless Scalar::Util::blessed($thing);
    $self->add_raw_route($thing);
}

sub reset {
    my $self = shift;
    $self->clear_routes;
    $self->clear_named_routes;
    return $self;
}

sub match {
    my ($self, $req) = @_;

    for my $route ($self->routes) {
        next unless my $match = $route->match($req);
        return $match;
    }

    return;
}

sub route_for {
    my ($self, $req) = @_;

    if (my $match = $self->match($req)) {
        return $match->route;
    }

    return;
}

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
