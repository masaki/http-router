package HTTP::Router::Declare;

use strict;
use warnings;
use Carp ();
use Clone ();
use HTTP::Router;
use HTTP::Router::Route;
use Data::Dump qw(dump);

sub import {
    my $caller = caller;

    no strict 'refs';
    no warnings 'redefine';

    *{ $caller . '::router' } = \&routing;
    *{ $caller . '::routes' } = \&routing;
    *{ $caller . '::to'     } = \&params;
    *{ $caller . '::into'   } = \&block;
    # lexical bindings
    *{ $caller . '::match'  } = sub { goto &match };
    *{ $caller . '::with'   } = sub { goto &with  };
}

sub routing (&) {
    my $block  = shift;
    my $router = HTTP::Router->new;

    if ($block) {
        no warnings 'redefine';

        local *match = sub {
            my $route = _match(@_);
            $router->add_route($route) if $route;
        };
        local *with = sub {
            my $route = _with(@_);
            $router->add_route($route) if $route;
        };

        my $root = HTTP::Router::Route->new;
        $block->($root);
    }

    return $router;
}

sub params ($) { params => $_[0] }
sub block  (&) { block  => $_[0] }

sub _match {
    my %args;

    while (@_) {
        if (ref $_[0] eq 'HASH') {
            $args{conditions} = shift;
        }
        elsif ($_[0] =~ /^(?:params|block)$/) {
            my $key = shift;
            $args{$key} = shift;
        }
        else {
            $args{path}       = shift;
            $args{conditions} = shift if ref $_[0] eq 'HASH';
        }
    }

    my $route = _route_for(%args);

    if (exists $args{block}) {
        $args{block}->($route);
        return;
    }
    else {
        return $route;
    }
}

sub _with {
    my %args = (params => shift, @_);

    my $route = _route_for(%args);
    $args{block}->($route);
    return;
}

sub _route_for {
    my %args = @_;
    my $route = Clone::clone( _caller_route() );

    if (exists $args{path}) {
        $route->append_path($args{path});
    }
    if (exists $args{conditions}) {
        $route->add_conditions(%{ $args{conditions} });
    }
    if (exists $args{params}) {
        $route->add_params(%{ $args{params} });
    }

    return $route->freeze;
}

sub _caller_route {
    package DB;
    () = caller(4);
    return [ @DB::args ]->[0];
}

sub _stub {
    my $name = shift;
    return sub {
        Carp::croak("Can't call $name() outside routing block");
    };
}

*match = _stub 'match';
*with  = _stub 'with';

1;

=head1 NAME

HTTP::Router::Declare

=head1 SYNOPSIS

  use HTTP::Router::Declare;

  my $router = router {
      match '/index.{format}'
          => to { controller => 'Root', action => 'index' };

      match '/archives/{year}', { year => qr/\d{4}/ }
          => to { controller => 'Archive', action => 'by_month' };

      match '/account/login', { method => ['GET', 'POST'] }
          => to { controller => 'Account', action => 'login' };

      with { controller => 'Account' } => into {
          match '/account/signup' => to { action => 'signup' };
          match '/account/logout' => to { action => 'logout' };
      };

      match '/{controller}/{action}/{id}';
  });

=head1 METHODS

=head2 router $block

=head2 match $path?, $conditions?

=head2 to $params

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
