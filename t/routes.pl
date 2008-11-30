[
    # /
    [ "/" => { controller => "Root", action => "index" } ],

    # GET /account/login
    # POST /account/login
    [ "/account/login" => {
        controller => "Account", action => "login",
        conditions => { method => ["GET", "POST"] },
    }],

    # GET /articles
    [ "/articles" => {
        controller => "Article", action => "index",
        conditions => { method => "GET" },
    }],
    # GET /articles/new
    [ "/articles/new" => {
        controller => "Article", action => "post",
        conditions => { method => "GET" },
    }],
    # POST /articles
    [ "/articles" => {
        controller => "Article", action => "create",
        conditions => { method => "POST" },
    }],
    # GET /articles/{article_id}
    [ "/articles/{article_id}" => {
        controller => "Article", action => "show",
        conditions => { method => "GET" },
    }],
    # GET /articles/{article_id}/edit
    [ "/articles/{article_id}/edit" => {
        controller => "Article", action => "edit",
        conditions => { method => "GET" },
    }],
    # PUT /articles/{article_id}
    [ "/articles/{article_id}" => {
        controller => "Article", action => "update",
        conditions => { method => "PUT" },
    }],
    # DELETE /articles/{article_id}
    [ "/articles/{article_id}" => {
        controller => "Article", action => "destroy",
        conditions => { method => "DELETE" },
    }],
]
