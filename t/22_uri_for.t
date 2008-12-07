use t::Router;

plan tests => 1 * blocks;

my $router = build_router();

filters {
    params => ['yaml'],
};

run {
    my $block = shift;
    is $router->uri_for($block->params) => $block->path, $block->name;
};

__END__
=== /
--- path: /
--- params
controller: Root
action: index

=== /account/login
--- path: /account/login
--- params
controller: Account
action: login

=== /archives/{year}
--- path: /archives/2008
--- params
controller: Archive
action: by_year
year: 2008

=== /archives/{year}/{month}
--- path: /archives/2008/12
--- params
controller: Archive
action: by_month
year: 2008
month: 12

=== /archives/{year}/{month}/{day}
--- path: /archives/2008/12/31
--- params
controller: Archive
action: by_day
year: 2008
month: 12
day: 31

=== /articles (index)
--- path: /articles
--- params
controller: Article
action: index

=== /articles/new
--- path: /articles/new
--- params
controller: Article
action: post

=== /articles (create)
--- path: /articles
--- params
controller: Article
action: create

=== /articles/{article_id} (show)
--- path: /articles/14
--- params
controller: Article
action: show
article_id: 14

=== /articles/{article_id}/edit
--- path: /articles/14/edit
--- params
controller: Article
action: edit
article_id: 14

=== /articles/{article_id} (update)
--- path: /articles/15
--- params
controller: Article
action: update
article_id: 15

=== /articles/{article_id} (destroy)
--- path: /articles/16
--- params
controller: Article
action: destroy
article_id: 16
