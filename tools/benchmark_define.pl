#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(:hireswallclock timethese);
use Test::MockObject;
use FindBin::libs;
use HTTP::Router::Declare;

timethese(10000, {
    match_to   => \&_match_to,
    path_then  => \&_path_then,
    conds_then => \&_conds_then,
    to_then    => \&_to_then,
    with       => \&_with,
});

sub _match_to {
    router {
        match '/' => to { controller => 'Root', action => 'index' };
    };
}

sub _path_then {
    router {
        match '/account' => then {
            match '/login', { method => 'POST' } => to { controller => 'Account', action => 'login'  };
        };
    };
}

sub _conds_then {
    router {
        match { method => 'POST' } => then {
            match '/account/login' => to { controller => 'Account', action => 'login'  };
        };
    };
}

sub _to_then {
    router {
        match '/account' => to { controller => 'account' } => then {
            match '/login', { method => 'POST' } => to { action => 'login'  };
        };
    };
}

sub _with {
    router {
        with { controller => '/account' } => then {
            match '/account/login', { method => 'POST' } => to { action => 'login'  };
        };
    };
}
