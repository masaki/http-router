package HTTP::Router;

use 5.8.1;
use Moose;
use MooseX::AttributeHelpers;
use HTTP::Router::Route;

has 'routes' => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[HTTP::Router::Route]',
    auto_deref => 1,
    default    => sub { [] },
    provides   => {
        push => 'connect',
    },
);

around 'connect' => sub {
    my ($orig, $self, $path, $args) = @_;
    $orig->($self, $self->_build_route($path, $args));
};

our $VERSION = '0.01';

sub _build_route {
    my ($self, $path, $args) = @_;

    $args ||= {};
    my $conditions   = delete $args->{conditions}   || {};
    my $requirements = delete $args->{requirements} || {};

    return HTTP::Router::Route->new(
        path         => $path,
        params       => $args,
        conditions   => $conditions,
        requirements => $requirements,
    );
}

sub match {
    my ($self, $path, $args) = @_;

    my $conditions = $args || {};
    for my $route ($self->routes) {
        if (my $match = $route->match($path, $conditions)) {
            return $match;
        }
    }

    return;
}

sub uri_for {
    my ($self, @args) = @_;

    for my $route ($self->routes) {
        if (my $uri = $route->uri_for(@args)) {
            return $uri;
        }
    }

    return;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 NAME

HTTP::Router - Yet Another HTTP Dispatcher

=head1 SYNOPSIS

  use HTTP::Router;

  my $router = HTTP::Router->new;

  $router->connect('/' => {
      controller => 'Root',
      action     => 'index',
  });

  $router->connect('/archives/{year}/{month}' => {
      controller   => 'Archive',
      action       => 'by_month',
      requirements => { year => qr/\d{4}/, month => qr/\d{2}/ },
  });

  $router->connect('/users/{username}' => {
      controller   => 'User',
      action       => 'show',
      requirements => { username => 'masaki' },
  });

  $router->connect('/account/login' => {
      controller => 'Account',
      action     => 'login',
      conditions => { method => ['GET', 'POST'] },
  });

  $router->connect('/articles/{article_id}' => {
      controller => 'Article',
      action     => 'show',
      conditions => { method => 'GET' },
  });
  $router->connect('/articles/{article_id}' => {
      controller => 'Article',
      action     => 'update',
      conditions => { method => 'PUT' },
  });
  $router->connect('/articles/{article_id}' => {
      controller => 'Article',
      action     => 'destroy',
      conditions => { method => 'DELETE' },
  });

  if ( my $match = $router->match('/') ){
      print $match->path; # '/'

      print $match->params->{controller}; # 'Root'
      print $match->params->{action};     # 'index'
  }

  if ( my $match = $router->match('/articles/14', { method => 'PUT' }) ){
      print $match->path; # '/articles/14'

      print $match->params->{controller}; # 'Article'
      print $match->params->{action};     # 'update'
      print $match->params->{article_id}; # '14'
  }

=head1 DESCRIPTION

HTTP::Router is HTTP Dispatcher

=head1 METHODS

=head2 new

=head2 connect($path, $args)

=head2 match($path, $conditions)

=head2 uri_for($args)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTPx::Dispatcher>, L<Path::Router>, L<Path::Dispatcher>

=cut
