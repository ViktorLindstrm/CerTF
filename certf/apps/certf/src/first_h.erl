%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(first_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(Name,"charles").
init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    logger:debug("Method: ~p~n",[Method]),
    page(Method,Req0,Opts).

page(<<"POST">>,Req0,Opts) -> 
    {ok, PostVals, Req} = cowboy_req:read_urlencoded_body(Req0),
    Flag = proplists:get_value(<<"flag">>, PostVals),
    Resp = layout:solution("first",Flag,sol()),
    Req2 = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [Resp], Req),
    {ok, Req2, Opts};


page(<<"GET">>,Req0,Opts) -> 
    Resp = layout:content(challenge(),"First"),
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [Resp], Req0),
    {ok, Req, Opts}.

challenge() ->
    ["<h2> Challenge 1 </h2>",
     "<p>
     The first Challenge is to find information within the server certificate. <br>
     This challenge consists of two flags, so make sure to find both of them.
    </p>
     "].

sol() -> 
    ["<p>Not only the server certificate but also the intermediate and Root Certifcate are of importance</p>"].
