#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(:hireswallclock timethese);
use Test::MockObject;
use FindBin::libs;
use HTTP::Router::Declare;

my $router = router {
    match '/' => to { controller => 'Root', action => 'index' };
    match '/account/login', { method => 'POST' } => to { controller => 'Account', action => 'login' };
    match '/archives/{year}', { year => qr/^\d{4}$/ } => to { controller => 'Archives', action => 'by_year' };
    resources 'Users';
    resource 'Admin';
};

my $path_request       = request(path => '/');
my $conditions_request = request(path => '/account/login', method => 'POST');
my $validate_request   = request(path => '/archives/2009');
my $resources_request  = request(path => '/users/new', method => 'GET');
my $resource_request   = request(path => '/admin/edit', method => 'GET');

timethese(10000, {
    path       => \&_path,
    conditions => \&_conditions,
    validate   => \&_validate,
    resources  => \&_resources,
    resource   => \&_resource,
});

sub request {
    my $r = Test::MockObject->new;
    my %p = @_;
    while (my ($k, $v) = each %p) {
        $r->set_always($k, $v);
    }
    $r;
}

sub _path       { $router->match($path_request)       }
sub _conditions { $router->match($conditions_request) }
sub _validate   { $router->match($validate_request)   }
sub _resources  { $router->match($resources_request)  }
sub _resource   { $router->match($resource_request)   }
