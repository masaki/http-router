package HTTP::Router;

use 5.8.1;
use Moose;
use MooseX::AttributeHelpers;
use HTTP::Router::Route;
use HTTP::Router::Debug;
use HTTP::Router::Builder;

our $VERSION = '0.01';

has 'routes' => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef[HTTP::Router::Route]',
    auto_deref => 1,
    default    => sub { [] },
    provides   => {
        push => 'add_route',
    },
);

sub connect {
    my ($self, $path, $args) = @_;

    my $route = HTTP::Router::Builder->new->build_connect($path, $args);
    $self->add_route($route);
}

sub resource {
    my ($self, $controller, $args) = @_;

    my @routes = HTTP::Router::Builder->new->build_resource($controller, $args);
    $self->add_route($_) for @routes;
}

sub resources {
    Carp::croak 'Implement me';
}

sub match {
    my ($self, $path, $conditions) = @_;

    my $slashes = scalar @{[ $path =~ m!/!g ]};
    my @routes  = grep { $_->slashes eq $slashes } $self->routes;

    # by path
    if (my @match = grep { defined } map { $_->match($path, $conditions) } @routes) {
        return wantarray ? @match : shift(@match);
    }

    # with expansions
    my @match = grep { defined } map { $_->match_with_expansions($path, $conditions) } @routes;
    return wantarray ? @match : shift(@match);
}

sub uri_for {
    my ($self, $args) = @_;

    $args ||= {};
    for my $route ($self->routes) {
        if (my $path = $route->uri_for($args)) {
            return $path;
        }
    }

    return;
}

sub show_table {
    my $self = shift;
    HTTP::Router::Debug->show_table($self->routes);
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 NAME

HTTP::Router - Yet Another HTTP Dispatcher

=head1 SYNOPSIS

  use HTTP::Router;

  my $router = HTTP::Router->new;

  $router->connect('/' => { controller => 'Root', action => 'index' });

  $router->connect('/archives/{year}/{month}' => {
      controller   => 'Archive',
      action       => 'by_month',
      requirements => { year => qr/\d{4}/, month => qr/\d{2}/ },
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

  my $match = $router->match('/');
  $match->path;   # '/'
  $match->params; # { controller => 'Root', action => 'index' }

  $match = $router->match('/archives/2008/12');
  # $match->params:
  # {
  #     controller => 'Archive',
  #     action     => 'by_month',
  #     year       => '2008',
  #     month      => '12',
  # }

  my @match = $router->match('/articles/14');
  print scalar(@match); # 2

  $match = $router->match('/articles/14', { method => 'PUT' })
  # $match->params:
  # {
  #     controller => 'Article',
  #     action     => 'update',
  #     article_id => '14',
  # }

  my $path = $router->uri_for({ controller => 'Root', action => 'index' });
  print $path; # /

  $path = $router->uri_for({
      controller => 'Archive',
      action     => 'by_month',
      year       => '2009',
      month      => '01',
  });
  print $path; # /archives/2009/01

=head1 DESCRIPTION

HTTP::Router is HTTP Dispatcher.

=head1 METHODS

=head2 new

=head2 connect($path [, $args])

=head2 match($path [, $conditions])

=head2 uri_for($args)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTPx::Dispatcher>, L<Path::Router>, L<Path::Dispatcher>

=cut
