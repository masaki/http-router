package HTTP::Router::Declare;

use strict;
use warnings;
use Carp ();
use Clone ();
use HTTP::Router;
use HTTP::Router::Route;

sub import {
    my $caller = caller;

    no strict 'refs';
    no warnings 'redefine';

    *{ $caller . '::router' } = \&routing;
    *{ $caller . '::routes' } = \&routing; # alias router

    *{ $caller . '::as'   } = \&conditions;
    *{ $caller . '::to'   } = \&params;
    *{ $caller . '::into' } = \&block;

    # lexical bindings
    *{ $caller . '::match'      } = sub { goto &match      };
    *{ $caller . '::constraint' } = sub { goto &constraint };
    *{ $caller . '::with'       } = sub { goto &with       };
}

sub conditions ($) { conditions => $_[0] }
sub params     ($) { params     => $_[0] }
sub block      (&) { block      => $_[0] }

sub _stub {
    my $name = shift;
    return sub {
        Carp::croak("Can't call $name() outside routing block");
    };
}

*match      = _stub 'match';
*constraint = _stub 'constraint';
*with       = _stub 'with';

sub _bind {
    my ($router, $name) = @_;

    return sub {
        my %args = ($name, @_);

        my $route = do {
            package DB;
            () = caller(1);
            Clone::clone($DB::args[0]);
        };
        $route->append_path($args{path})               if exists $args{path};
        $route->add_conditions(%{ $args{conditions} }) if exists $args{conditions};
        $route->add_params(%{ $args{params} })         if exists $args{params};

        if (exists $args{block}) {
            $args{block}->($route);
        }
        else {
            $router->add_route($route);
        }
    };
}

sub routing (&) {
    my $block  = shift;
    my $router = HTTP::Router->new;

    if ($block) {
        no warnings 'redefine';

        local *match      = _bind $router, 'path';
        local *constraint = _bind $router, 'conditions';
        local *with       = _bind $router, 'params';

        my $root = HTTP::Router::Route->new;
        $block->($root);
    }

    return $router;
}

1;

=head1 NAME

HTTP::Router::Declare

=head1 SYNOPSIS

  use HTTP::Router::Declare;

  my $router = router {
      # match (path), as (conditions), and to (params)
      match '/'                                          => to { controller => 'Root', action => 'index' };
      match '/home'        => as { method => 'GET' }     => to { controller => 'Home', action => 'show' };
      match '/date/{year}' => as { year => qr/^\d{4}$/ } => to { controller => 'Date', action => 'by_year' };
 
      # match (path), to (params), and into (block)
      match '/account' => to { controller => 'Account' } => into {
          match '/login'  => to { action => 'login' };
          match '/logout' => to { action => 'logout' };
      };
 
      # match (path) and into (block)
      match '/account' => into {
          match '/signup' => to { controller => 'Users',   action => 'register' };
          match '/logout' => to { controller => 'Account', action => 'logout' };
      };
 
      # constraint (conditions) and into (block)
      constraint { method => 'GET' } => into {
          match '/search' => to { controller => 'Items', action => 'search' };
          match '/tags'   => to { controller => 'Tags',  action => 'index' };
      };
 
      # with (params) and into (block)
      with { controller => 'Account' } => into {
          match '/login'  => to { action => 'login' };
          match '/logout' => to { action => 'logout' };
      };
 
      # match only (Mapper's register)
      match '/{controller}/{action}/{id}.{format}';
      match '/{controller}/{action}/{id}';
  };

=head1 METHODS

=head2 router $block

=head2 match $path

=head2 as $conditions

=head2 to $params

=head2 constraint $conditions

=head2 with $params

=head2 into $block

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<HTTP::Router::Route>

=cut
