#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Router;
use Getopt::Long;
use Pod::Usage;
use Test::MockObject;

my %argv = ( loop => 1, );
GetOptions( \%argv, "loop=i", ) or $argv{help}++;

main();

sub main {
    #enable_profiling_if_nessesary();
    my $router = create_router();
    for ( 0 .. $argv{loop} ) {
        my $req = create_request( { path => '/' } );
        my $match = $router->match($req);
    }
}

sub enable_profiling_if_nessesary {
    if ( !$ENV{NO_NYTPROF} ) {
        require Devel::NYTProf;
        $ENV{NYTPROF} = 'start=no';
        Devel::NYTProf->import;
        DB::enable_profile();
    }
}

sub create_request {
    my $params = shift;
    my $req    = Test::MockObject->new;
    while ( my ( $name, $value ) = each %$params ) {
        $req->set_always( $name, $value );
    }
    $req;
}

sub create_router {
    HTTP::Router->define(
        sub {
            $_->match('/')->to( { controller => 'Root', action => 'index' } );
        }
    );
}


