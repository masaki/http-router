[
    # /
    [ "/" => { controller => "Root", action => "index" } ],

    # /account/login
    [ "/account/login" => {
        controller => "Account", action => "login",
        conditions => { method => ["GET", "POST"] },
    }],

    # /articles/{article_id}
    [ "/articles/{article_id}" => {
        controller => "Article", action => "show",
        conditions => { method => "GET" },
    }],
    [ "/articles/{article_id}" => {
        controller => "Article", action => "update",
        conditions => { method => "PUT" },
    }],
    [ "/articles/{article_id}" => {
        controller => "Article", action => "destroy",
        conditions => { method => "DELETE" },
    }],
]
