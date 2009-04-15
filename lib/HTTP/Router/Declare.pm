package HTTP::Router::Declare;

use strict;
use warnings;
use Carp 'croak';
use Storable;
use HTTP::Router;
use HTTP::Router::Route;

sub import {
    my $caller = caller;

    no strict 'refs';
    no warnings 'redefine';

    *{ $caller . '::router' } = \&routing;
    *{ $caller . '::routes' } = \&routing; # alias router

    # lexical bindings
    *{ $caller . '::match' } = sub { goto &match };
    *{ $caller . '::with'  } = sub { goto &with  };
    *{ $caller . '::to'    } = sub ($) { goto &to   };
    *{ $caller . '::then'  } = sub (&) { goto &then };
}

sub _stub {
    my $name = shift;
    return sub { croak "Can't call $name() outside routing block" };
}

*match = _stub 'match';
*with  = _stub 'with';
*to    = _stub 'to';
*then  = _stub 'then';

sub routing (&) {
    my $block  = shift;
    my $router = HTTP::Router->new;

    if ($block) {
        no warnings 'redefine';

        local *match = create_match($router);
        local *with  = create_with($router);
        local *to    = sub { params => $_[0] };
        local *then  = sub { block  => $_[0] };

        my $root = HTTP::Router::Route->new;
        $block->($root);
    }

    return $router;
}

sub _map {
    my ($router, %args) = @_;

    my $route = do {
        package DB;
        () = caller(2);
        Storable::dclone($DB::args[0]);
    };
    $route->append_path($args{path})               if exists $args{path};
    $route->add_conditions(%{ $args{conditions} }) if exists $args{conditions};
    $route->add_params(%{ $args{params} })         if exists $args{params};

    return exists $args{block} ? $args{block}->($route) : $router->add_route($route);
}

sub create_match {
    my $router = shift;
    return sub {
        my %args = ();
        $args{path}       = shift unless ref $_[0];
        $args{conditions} = shift if ref $_[0] eq 'HASH';
        _map $router, %args, @_;
    };
}

sub create_with {
    my $router = shift;
    return sub { _map $router, params => @_ };
}

1;

=head1 NAME

HTTP::Router::Declare

=head1 SYNOPSIS

  use HTTP::Router::Declare;

  my $router = router {
      # path and params
      match '/' => to { controller => 'Root', action => 'index' };
  
      # path, conditions, and params
      match '/home', { method => 'GET' }
          => to { controller => 'Home', action => 'show' };
      match '/date/{year}', { year => qr/^\d{4}$/ }
          => to { controller => 'Date', action => 'by_year' };
  
      # path, params, and nesting
      match '/account' => to { controller => 'Account' } => then {
          match '/login'  => to { action => 'login' };
          match '/logout' => to { action => 'logout' };
      };
  
      # path nesting
      match '/account' => then {
          match '/signup' => to { controller => 'Users', action => 'register' };
          match '/logout' => to { controller => 'Account', action => 'logout' };
      };
  
      # conditions nesting
      match { method => 'GET' } => then {
          match '/search' => to { controller => 'Items', action => 'search' };
          match '/tags'   => to { controller => 'Tags', action => 'index' };
      };
  
      # params nesting
      with { controller => 'Account' } => then {
          match '/login'  => to { action => 'login' };
          match '/logout' => to { action => 'logout' };
          match '/signup' => to { action => 'signup' };
      };
  
      # match only
      match '/{controller}/{action}/{id}.{format}';
      match '/{controller}/{action}/{id}';
  };

=head1 METHODS

=head2 router $block

=head2 match $path?, $conditions?

=head2 to $params

=head2 with $params

=head2 then $block

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<HTTP::Router::Route>

=cut
