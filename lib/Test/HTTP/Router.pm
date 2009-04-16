package Test::HTTP::Router;

use strict;
use warnings;
use Exporter 'import';
use Test::Builder;
use Test::MockObject;

our @EXPORT = qw(
    path_ok path_not_ok
    match_ok match_not_ok
);

our $Test = Test::Builder->new;

sub request {
    my $args = ref $_[0] ? shift : { @_ };
    my $req = Test::MockObject->new;
    $req->set_always($_ => $args->{$_}) for keys %$args;
    $req;
}

sub path_ok {
    my ($router, $path, $message) = @_;
    my $req = request path => $path;
    $Test->ok($router->match($req) ? 1 : 0, $message || "matched $path");
}

sub path_not_ok {
    my ($router, $path, $message) = @_;
    my $req = request path => $path;
    $Test->ok($router->match($req) ? 0 : 1, $message || "not matched $path");
}

sub match_ok {
    my ($router, $path, $conditions, $message) = @_;
    my $req = request %{ $conditions || {} }, path => $path;
    $Test->ok($router->match($req) ? 1 : 0, $message || "matched $path with conditions");
}

sub match_not_ok {
    my ($router, $path, $conditions, $message) = @_;
    my $req = request %{ $conditions || {} }, path => $path;
    $Test->ok($router->match($req) ? 0 : 1, $message || "not matched $path with conditions");
}

1;
