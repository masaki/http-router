use t::Router;

plan tests => 1 * blocks;

my $router = build_router();

filters {
    conditions => ['eval'],
};

run {
    my $block = shift;
    my $match = $router->match($block->path, $block->conditions);
    ok !$match, $block->name;
};

__END__
=== GET /notfound (path not exists)
--- path: /notfound
--- conditions: { method => 'GET' }

=== GET /account/logout (path not exists)
--- path: /account/logout
--- conditions: { method => 'GET' }

=== PUT /account/login (method failure)
--- path: /account/login
--- conditions: { method => 'PUT' }

=== GET /articles/ (trailer slash)
--- path: /articles/
--- conditions: { method => 'GET' }

=== GET /articles.html (formatted)
--- path: /articles.html
--- conditions: { method => 'GET' }

=== PUT /articles (method failure)
--- path: /articles
--- conditions: { method => 'PUT' }

=== POST /articles/{article_id} (method failure)
--- path: /articles/14
--- conditions: { method => 'POST' }

=== GET /articles/{article_id}/comments (path not exists)
--- path: /articles/14/comments
--- conditions: { method => 'GET' }
