package HTTP::Router::Resources;

use Any::Moose '::Role';
use Hash::Merge 'merge';
use Lingua::EN::Inflect::Number qw(to_S to_PL);
use String::CamelCase qw(camelize decamelize);

requires qw(match fork);

no Any::Moose '::Role';

sub resources {
    my $block = ref $_[-1] eq 'CODE' ? pop : undef;
    my ($self, $name, $args) = @_;

    my $path     = decamelize $name;
    my $params   = { controller => $args->{controller} || camelize(to_PL($path)) };
    my $singular = $args->{singular} || to_S($path);
    my $id       = "${singular}_id";

    my $collections = merge($args->{collection} || {}, {
        index  => { method => 'GET',  path => '' },
        create => { method => 'POST', path => '' },
        post   => { method => 'GET',  path => '/new' },
    });

    my $members = merge($args->{member} || {}, {
        show    => { method => 'GET',    path => '' },
        update  => { method => 'PUT',    path => '' },
        destroy => { method => 'DELETE', path => '' },
        edit    => { method => 'GET',    path => '/edit' },
    });

    $self->match("/${path}")->to($params, sub {
        # collections
        while (my ($action, $args) = each %$collections) {
            my $path   = ref $args eq 'HASH' ? $args->{path}   : "/${action}";
            my $method = ref $args eq 'HASH' ? $args->{method} : $args;
            my $conditions = { method => $method };
            my $params     = { action => $action };
            $_[0]->match("${path}.{format}", $conditions)->to($params);
            $_[0]->match("${path}",          $conditions)->to($params);
        }

        # members
        $_[0]->match("/{$id}", sub {
            while (my ($action, $args) = each %$members) {
                my $path   = ref $args ? $args->{path}   : "/${action}";
                my $method = ref $args ? $args->{method} : $args;
                my $conditions = { method => $method };
                my $params     = { action => $action };
                $_[0]->match("${path}.{format}", $conditions)->to($params);
                $_[0]->match("${path}",          $conditions)->to($params);
            }
        });
    });

    if ($block) {
        local $_ = $self->fork(path => $self->path . "/${path}/{$id}");
        $block->($_);
    }

    $self;
}

sub resource {
    my $self = shift;

    my $block = ref $_[-1] eq 'CODE' ? pop : undef;
    my ($name, $args) = @_;

    my $path   = decamelize $name;
    my $params = { controller => $args->{controller} || camelize($path) };

    my $members = merge($args->{member} || {}, {
        create  => { method => 'POST',   path => '' },
        show    => { method => 'GET',    path => '' },
        update  => { method => 'PUT',    path => '' },
        destroy => { method => 'DELETE', path => '' },
        post    => { method => 'GET',    path => '/new' },
        edit    => { method => 'GET',    path => '/edit' },
    });

    $self->match("/${path}")->to($params, sub {
        # members
        while (my ($action, $args) = each %$members) {
            my $path   = ref $args eq 'HASH' ? $args->{path}   : "/${action}";
            my $method = ref $args eq 'HASH' ? $args->{method} : $args;
            my $conditions = { method => $method };
            my $params     = { action => $action };
            $_[0]->match("${path}.{format}", $conditions)->to($params);
            $_[0]->match("${path}",          $conditions)->to($params);
        }
    });

    if ($block) {
        local $_ = $self->fork(path => $self->path . "/${path}");
        $block->($_);
    }

    $self;
}

# apply roles
__PACKAGE__->meta->apply( HTTP::Router::Mapper->meta );

1;

=head1 NAME

HTTP::Router::Resources

=head1 SYNOPSIS

  use HTTP::Router;
  use HTTP::Router::Resources;

  my $router = HTTP::Router->define(sub {
      $_->resources('users');

      $_->resource('account');

      $_->resources('members', sub {
          $_->resources('articles');
      });

      $_->resources('members', {
          controller => 'Users',
          collection => { login => 'GET' },
          member     => { settings => 'GET' },
      });
  });

=head1 METHODS

=head2 resources($name, $args?, $block?)

=head2 resource($name, $args?, $block?)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router::Mapper>, L<HTTP::Router>

=cut
