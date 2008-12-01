use t::Router;

plan tests => 1 * blocks;

my $router = build_router();

filters {
    conditions => ['eval'],
    params     => ['yaml'],
};

run {
    my $block = shift;
    my @match = $router->match($block->path);
    is_deeply [ map { $_->params } @match ], $block->params, $block->name;
};

__END__
=== /
--- path: /
--- params
- controller: Root
  action: index

=== /account/login
--- path: /account/login
--- params
- controller: Account
  action: login

=== /archives/{year}
--- path: /archives/2008
--- params
- controller: Archive
  action: by_year
  year: 2008

=== /archives/{year}/{month}
--- path: /archives/2008/12
--- params
- controller: Archive
  action: by_month
  year: 2008
  month: 12

=== /archives/{year}/{month}/{day}
--- path: /archives/2008/12/31
--- params
- controller: Archive
  action: by_day
  year: 2008
  month: 12
  day: 31

=== /articles
--- path: /articles
--- params
- controller: Article
  action: index
- controller: Article
  action: create

=== /articles/{article_id}
--- path: /articles/14
--- params
- controller: Article
  action: show
  article_id: 14
- controller: Article
  action: update
  article_id: 14
- controller: Article
  action: destroy
  article_id: 14
