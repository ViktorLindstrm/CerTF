%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(main_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(Name,"viktor").

main() -> 
    ["<main role=\"main\">",

    "<div class=\"container marketing\">",
    "<h1>CerTF</h1>
    <h2>Welcome to this Certificate CTF challenge!</h2>
    <p>
    CerTF is a collection of a few small challenges to help and make it a
    little fun to understanding of certificates and how to read/create them.
    Mainly focus is client authentication with certificates, although
    understanding of PKI and certificates
    </p>

    <p>
    More challenges are in planing, if you have an idea, put it as a issue here.
    Prettier and more info regarding challenges are also in the making.
    </p>

    <p>
    Some of the challenges are more \"real\" than other, little regard has been taken
    to this to be \"real\" cases.
    </p>
    <code>
    Challenges has flag format: certf{FLAG}
    </code> 
    </main>"
    ].

init(Req0, Opts) ->
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [layout:content_sol(main(),"Home")], Req0),
    {ok, Req, Opts}.

