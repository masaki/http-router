use t::Router;

plan tests => 2 * blocks;

my $router = build_router();

filters {
    conditions => ['eval'],
    params     => ['yaml'],
};

run {
    my $block = shift;
    my $match = $router->match($block->path, $block->conditions);
    is_deeply $match->params, $block->params, "@{[ $block->name ]} (params)";
    is $match->path, $block->path, "@{[ $block->name ]} (path)";
};

__END__
=== /
--- path: /
--- params
controller: Root
action: index

=== GET /
--- path: /
--- conditions: { method => 'GET' }
--- params
controller: Root
action: index

=== POST /
--- path: /
--- conditions: { method => 'POST' }
--- params
controller: Root
action: index

=== GET /account/login
--- path: /account/login
--- conditions: { method => 'GET' }
--- params
controller: Account
action: login

=== POST /account/login
--- path: /account/login
--- conditions: { method => 'POST' }
--- params
controller: Account
action: login

=== GET /archives/{year}
--- path: /archives/2008
--- params
controller: Archive
action: by_year
year: 2008

=== GET /archives/{year}/{month}
--- path: /archives/2008/12
--- params
controller: Archive
action: by_month
year: 2008
month: 12

=== GET /archives/{year}/{month}/{day}
--- path: /archives/2008/12/31
--- params
controller: Archive
action: by_day
year: 2008
month: 12
day: 31

=== GET /articles
--- path: /articles
--- conditions: { method => 'GET' }
--- params
controller: Article
action: index

=== GET /articles/new
--- path: /articles/new
--- conditions: { method => 'GET' }
--- params
controller: Article
action: post

=== POST /articles
--- path: /articles
--- conditions: { method => 'POST' }
--- params
controller: Article
action: create

=== GET /articles/{article_id}
--- path: /articles/14
--- conditions: { method => 'GET' }
--- params
controller: Article
action: show
article_id: 14

=== GET /articles/{article_id}/edit
--- path: /articles/14/edit
--- conditions: { method => 'GET' }
--- params
controller: Article
action: edit
article_id: 14

=== PUT /articles/{article_id}
--- path: /articles/15
--- conditions: { method => 'PUT' }
--- params
controller: Article
action: update
article_id: 15

=== DELETE /articles/{article_id}
--- path: /articles/16
--- conditions: { method => 'DELETE' }
--- params
controller: Article
action: destroy
article_id: 16
