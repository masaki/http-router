use Test::Base;
use Test::Deep;
use t::Router;
use HTTP::Router;

plan tests => 1 + 2*blocks;

filters { map { $_ => ['eval'] } qw(request results) };

my $router = HTTP::Router->define(sub {
    $_->resources('Users', sub {
        $_->resources('Articles');
    });
});

is scalar @{[ $router->routes ]} => 28;

run {
    my $block = shift;
    my $req = create_request($block->request);

    my $match = $router->match($req);
    ok $match;
    cmp_deeply $match->params => $block->results;
};

__END__
=== index
--- request: { path => '/users/10/articles', method => 'GET' }
--- results: { controller => 'Articles', action => 'index', user_id => 10 }

=== formatted index
--- request: { path => '/users/10/articles.html', method => 'GET' }
--- results: { controller => 'Articles', action => 'index', user_id => 10, format => 'html' }

=== new
--- request: { path => '/users/10/articles/new', method => 'GET' }
--- results: { controller => 'Articles', action => 'post', user_id => 10 }

=== formatted new
--- request: { path => '/users/10/articles/new.html', method => 'GET' }
--- results: { controller => 'Articles', action => 'post', user_id => 10, format => 'html' }

=== create
--- request: { path => '/users/10/articles', method => 'POST' }
--- results: { controller => 'Articles', action => 'create', user_id => 10 }

=== formatted create
--- request: { path => '/users/10/articles.html', method => 'POST' }
--- results: { controller => 'Articles', action => 'create', user_id => 10, format => 'html' }

=== show
--- request: { path => '/users/10/articles/20', method => 'GET' }
--- results: { controller => 'Articles', action => 'show', user_id => 10, article_id => 20 }

=== formatted show
--- request: { path => '/users/10/articles/20.html', method => 'GET' }
--- results: { controller => 'Articles', action => 'show', user_id => 10, article_id => 20, format => 'html' }

=== edit
--- request: { path => '/users/10/articles/20/edit', method => 'GET' }
--- results: { controller => 'Articles', action => 'edit', user_id => 10, article_id => 20 }

=== formatted edit
--- request: { path => '/users/10/articles/20/edit.html', method => 'GET' }
--- results: { controller => 'Articles', action => 'edit', user_id => 10, article_id => 20, format => 'html' }

=== update
--- request: { path => '/users/10/articles/20', method => 'PUT' }
--- results: { controller => 'Articles', action => 'update', user_id => 10, article_id => 20 }

=== formatted update
--- request: { path => '/users/10/articles/20.html', method => 'PUT' }
--- results: { controller => 'Articles', action => 'update', user_id => 10, article_id => 20, format => 'html' }

=== destroy
--- request: { path => '/users/10/articles/20', method => 'DELETE' }
--- results: { controller => 'Articles', action => 'destroy', user_id => 10, article_id => 20 }

=== formatted destroy
--- request: { path => '/users/10/articles/20.html', method => 'DELETE' }
--- results: { controller => 'Articles', action => 'destroy', user_id => 10, article_id => 20, format => 'html' }
