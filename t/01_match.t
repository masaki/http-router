use t::Router;

plan tests => 1 * blocks;

my $router = build_router();

filters {
    conditions => ['eval'],
    expected   => ['yaml'],
};

run {
    my $block = shift;
    my $match = $router->match($block->path, $block->conditions);
    is_deeply $match, $block->expected, $block->name;
};

__END__
=== /
--- path: /
--- expected
controller: Root
action: index

=== GET /
--- path: /
--- conditions: { method => 'GET' }
--- expected
controller: Root
action: index

=== POST /
--- path: /
--- conditions: { method => 'POST' }
--- expected
controller: Root
action: index

=== GET /account/login
--- path: /account/login
--- conditions: { method => 'GET' }
--- expected
controller: Account
action: login

=== POST /account/login
--- path: /account/login
--- conditions: { method => 'POST' }
--- expected
controller: Account
action: login

=== GET /articles
--- path: /articles
--- conditions: { method => 'GET' }
--- expected
controller: Article
action: index

=== GET /articles/new
--- path: /articles/new
--- conditions: { method => 'GET' }
--- expected
controller: Article
action: post

=== POST /articles
--- path: /articles
--- conditions: { method => 'POST' }
--- expected
controller: Article
action: create

=== GET /articles/{article_id}
--- path: /articles/14
--- conditions: { method => 'GET' }
--- expected
controller: Article
action: show
article_id: 14

=== GET /articles/{article_id}/edit
--- path: /articles/14/edit
--- conditions: { method => 'GET' }
--- expected
controller: Article
action: edit
article_id: 14

=== PUT /articles/{article_id}
--- path: /articles/15
--- conditions: { method => 'PUT' }
--- expected
controller: Article
action: update
article_id: 15

=== DELETE /articles/{article_id}
--- path: /articles/16
--- conditions: { method => 'DELETE' }
--- expected
controller: Article
action: destroy
article_id: 16
