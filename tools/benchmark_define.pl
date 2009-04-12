#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(:hireswallclock timethese);
use Test::MockObject;
use FindBin::libs;
use HTTP::Router;

timethese(10000, {
    match       => \&match,
    match_block => \&match_block,
    to_block    => \&to_block,
    with        => \&with,
});

sub req {
    my $params = ref $_[0] ? shift : { @_ };
    my $req = Test::MockObject->new;
    while (my ($name, $value) = each %$params) {
        $req->set_always($name, $value);
    }
    $req;
}

sub match {
    my $router = HTTP::Router->define(sub {
        $_[0]->match('/')->to({ action => 'index' });
        $_[0]->match('/{year}', { year => qr/^\d{4}$/ })->to({ action => 'year' });
    });

    $router->match(req(path => '/'));
    $router->match(req(path => '/2009'));
}

sub match_block {
    my $router = HTTP::Router->define(sub {
        $_[0]->match('/account', sub {
            $_[0]->match('/login',  { method => 'POST' })->to({ action => 'login'  });
            $_[0]->match('/logout', { method => 'GET'  })->to({ action => 'logout' });
        });
    });

    $router->match(req(path => '/account/login',  method => 'POST'));
    $router->match(req(path => '/account/logout', method => 'GET' ));
}

sub to_block {
    my $router = HTTP::Router->define(sub {
        $_[0]->match('/account')->to({ controller => 'account' }, sub {
            $_[0]->match('/login',  { method => 'POST' })->to({ action => 'login'  });
            $_[0]->match('/logout', { method => 'GET'  })->to({ action => 'logout' });
        });
    });

    $router->match(req(path => '/account/login',  method => 'POST'));
    $router->match(req(path => '/account/logout', method => 'GET' ));
}

sub with {
    my $router = HTTP::Router->define(sub {
        $_[0]->with({ controller => '/account' }, sub {
            $_[0]->match('/login',  { method => 'POST' })->to({ action => 'login'  });
            $_[0]->match('/logout', { method => 'GET'  })->to({ action => 'logout' });
        });
    });

    $router->match(req(path => '/login',  method => 'POST'));
    $router->match(req(path => '/logout', method => 'GET' ));
}
