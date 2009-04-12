package HTTP::Router::Mapper;

use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use Carp ();
use Clone ();
use Hash::Merge 'merge';
use HTTP::Router::Route;

has 'router' => (
    is       => 'rw',
    isa      => 'HTTP::Router',
    required => 1,
);

has 'route' => (
    is        => 'rw',
    isa       => 'HTTP::Router::Route',
    predicate => 'has_route',
);

has 'path' => (
    is        => 'rw',
    isa       => 'Str',
    metaclass => 'String',
    default   => '',
    provides  => {
        append => 'append_path',
    },
);

has 'params' => (
    is        => 'rw',
    isa       => 'HashRef',
    metaclass => 'Collection::Hash',
    default   => sub { +{} },
    provides  => {
        set => 'add_params',
    },
);

has 'conditions' => (
    is        => 'rw',
    isa       => 'HashRef',
    metaclass => 'Collection::Hash',
    default   => sub { +{} },
    provides  => {
        set => 'add_conditions',
    },
);

before qw'match to with register' => sub {
    my $self = shift;
    Carp::croak('route has already been committed') if $self->has_route;
};

no Any::Moose;

sub fork {
    my ($self, %params) = @_;

    for my $key (qw'path params conditions') {
        $params{$key} = $self->$key unless exists $params{$key};
    }

    return $self->meta->name->new(
        %{ Clone::clone(\%params) },
        router => $self->router,
    );
}

sub register_route {
    my $self = shift;

    my $route = HTTP::Router::Route->new(
        path       => $self->path,
        params     => $self->params,
        conditions => $self->conditions,
    );

    $self->router->add_route($route);
    $self->route($route);

    return $self;
}

sub match {
    my $block = ref $_[-1] eq 'CODE' ? pop : undef;
    my ($self, $path, $conditions) = @_;
    Carp::croak('$path or $conditions is required') unless $path or $conditions;

    my %extra = (
        $path       ? (path       => $self->path . $path)                   : (),
        $conditions ? (conditions => merge($conditions, $self->conditions)) : (),
    );
    my $mapper = $self->fork(%extra);

    if ($block) {
        local $_ = $mapper;
        $block->($_);
    }

    return $mapper;
}

sub to {
    my $block = ref $_[-1] eq 'CODE' ? pop : undef;
    my ($self, $params) = @_;
    Carp::croak('$params is required') unless $params;

    $self->add_params(%$params);

    if ($block) {
        local $_ = $self;
        $block->($_);
    }
    else {
        $self->register_route;
    }

    return $self;
}

sub with {
    my $block = ref $_[-1] eq 'CODE' ? pop : undef;
    my ($self, $params) = @_;
    Carp::croak('$params and $block are required') unless $params and $block;

    local $_ = $self->fork(params => merge($params, $self->params));
    $block->($_);

    return $_;
}

sub register { $_[0]->register_route }

# TODO: not implemented yet
#sub namespace {}
#sub name {}

__PACKAGE__->meta->make_immutable;

=for stopwords params

=head1 NAME

HTTP::Router::Mapper

=head1 SYNOPSIS

  my $router = HTTP::Router->define(sub {
      $_->match('/index.{format}')
          ->to({ controller => 'Root', action => 'index' });

      $_->match('/archives/{year}', { year => qr/\d{4}/ })
          ->to({ controller => 'Archive', action => 'by_month' });

      $_->match('/account/login', { method => ['GET', 'POST'] })
          ->to({ controller => 'Account', action => 'login' });

      $_->with({ controller => 'Account' }, sub {
          $_->match('/account/signup')->to({ action => 'signup' });
          $_->match('/account/logout')->to({ action => 'logout' });
      });

      $_->match('/')->register;
  });

=head1 METHODS

=head2 match($path?, $conditions?, $block?)

=head2 to($params, $block?)

=head2 with($params, $block)

=head2 register

=head1 PROPERTIES

=head2 path

=head2 conditions

=head2 params

=head2 route

=head2 router

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTTP::Router>, L<HTTP::Router::Route>

=cut
