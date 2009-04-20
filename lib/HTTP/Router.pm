package HTTP::Router;

use 5.008_001;
use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use Carp 'carp';
use Hash::AsObject;
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
        push  => 'add_raw_route',
        clear => 'clear_routes',
    },
);

has 'named_routes' => (
    is         => 'ro',
    isa        => 'HashRef',
    metaclass  => 'Collection::Hash',
    lazy       => 1,
    builder    => '_build_named_routes',
    auto_deref => 1,
    provides   => {
        set   => 'add_named_route',
        clear => 'clear_named_routes',
    },
);

has 'matcher' => (
    is        => 'rw',
    isa       => 'CodeRef',
    predicate => 'compiled',
    clearer   => 'clear_matcher',
);

sub _build_routes       { [] }
sub _build_named_routes { {} }

sub add_route {
    my ($self, $thing, %args) = @_;
    $thing = HTTP::Router::Route->new(path => $thing, %args) unless blessed $thing;
    $self->add_raw_route($thing);
}

sub reset {
    my $self = shift;
    $self->clear_routes;
    $self->clear_named_routes;
    $self->clear_matcher;
    return $self;
}

sub compile {
    my $self = shift;

    $self->clear_matcher if $self->compiled;

    #my $code;
    #for my $route ($self->routes) {
    #    $code .= $route->generate_match;
    #}
    my $code = sub {}; # mock

    my $matcher = eval $code;
    $@ ? carp $@ : $self->matcher($matcher);

    $self;
}

sub match {
    my $self = shift;
    my $req  = blessed $_[0] ? $_[0] : Hash::AsObject->new(path => $_[0], %{ $_[1] || {} });

    for my $route ($self->routes) {
        next unless my $match = $route->match($req);
        return $match;
    }

    return;
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
