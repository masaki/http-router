[
    [ "/" => {
        defaults => { controller => "Root", action => "index" },
    }],

    [ "/account/login" => {
        defaults => { controller => "Account", action => "login" },
        conditions => { method => ["GET", "POST"] },
    }],

    [ "/articles/{article_id}" => {
        defaults => { controller => "Article", action => "show" },
        conditions => { method => "GET" },
    }],

    [ "/articles/{article_id}" => {
        defaults => { controller => "Article", action => "update" },
        conditions => { method => "PUT" },
    }],

    [ "/articles/{article_id}" => {
        defaults => { controller => "Article", action => "destroy" },
        conditions => { method => "DELETE" },
    }],
]
