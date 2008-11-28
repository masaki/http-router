package HTTP::Router;

use 5.8.1;
use Moose;
use MooseX::AttributeHelpers;
use HTTP::Router::Route;

has 'routes' => (
    metaclass  => 'Collection::Array',
    is         => 'ro',
    isa        => 'ArrayRef[HTTP::Router::Route]',
    default    => sub { [] },
    auto_deref => 1,
    provides   => { 'push' => 'connect' },
);

around 'connect' => sub {
    my ($orig, $self, $path, $args) = @_;
    $orig->($self, $self->_build_route($path, $args));
};

our $VERSION = '0.01';

__PACKAGE__->meta->make_immutable;

no Moose;

sub _build_route {
    my ($self, $path, $args) = @_;

    $args ||= {};
    my $conditions   = delete $args->{conditions}   || {};
    my $requirements = delete $args->{requirements} || {};

    return HTTP::Router::Route->new(
        path         => $path,
        defaults     => $args,
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

1;

=head1 NAME

HTTP::Router - Yet Another HTTP Dispatcher

=head1 SYNOPSIS

  use HTTP::Router;

  my $router = HTTP::Router->new;

  $router->connect('/' => {
      defaults => { controller => 'Root', action => 'index' },
  });

  $router->connect('/archives/{year}/{month}' => {
      defaults => {
          controller => 'Archive',
          action     => 'show',
      },
      requirements => {
          year  => qr/\d{4}/,
          month => qr/\d{2}/,
      }
  });

  $router->connect('/users/{username}' => {
      defaults => {
          controller => 'User',
          action     => 'show',
      },
      requirements => { username => qr// },
  });

  $router->connect('/articles/{article_id}' => {
      defaults => {
          controller => 'Article',
          action     => 'show',
      },
      conditions => { method => 'GET' },
  });
  $router->connect('/articles/{article_id}' => {
      defaults => {
          controller => 'Article',
          action     => 'update',
      },
      conditions => { method => 'PUT' },
  });
  $router->connect('/articles/{article_id}' => {
      defaults => {
          controller => 'Article',
          action     => 'destroy',
      },
      conditions => { method => 'DELETE' },
  });

  $router->connect('/account/login' => {
      defaults => {
          controller => 'Account',
          action     => 'login',
      },
      conditions => { method => ['GET', 'POST'] },
  });

  # $req->uri is '/'
  if ( my $match = $router->match($req) ){
      print $match->{controller}; # 'Root'
      print $match->{action};     # 'index'
  }

  # $req->uri is '/articles/14'
  # $req->method is 'PUT'
  if ( my $match = $router->match($req) ){
      print $match->{controller}; # 'Article'
      print $match->{action};     # 'update'
      print $match->{article_id}; # '14'
  }

=head1 DESCRIPTION

HTTP::Router is HTTP Dispatcher

=head1 METHODS

=head2 new

=head2 connect($path, $args)

=head2 match($req)

=head2 uri_for($args)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTPx::Dispatcher>, L<Path::Router>

=cut
