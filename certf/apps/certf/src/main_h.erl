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
    little fun to understanding of certifciates and how to read/create them.
    Mainly focus is client authentication with certificates, although
    understanding of PKI and
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
    <br />
    <br />
    <p>
    The following three persons are the ones that the challenges include if nothing else is stated. i.e. these are the ones to try to bruteforce names etc.
    </p>",
    "<div class=\"row\">",
         create_presos(persons()),
    "</div><!-- /.row -->"
    "</main>"
    ].
persons() -> 
    [{"Ada","Development responsible"},{"Alan","Policy And Compliance"},{"Charles","Something Somewhere"}].

create_presos(L) -> lists:map(fun({Name,Desc}) -> person(Name,Desc) end, L).

person(Name,Desc) -> 
    ["<div class=\"col-lg-4\">",
    "<svg class=\"bd-placeholder-img rounded-circle\" width=\"140\" height=\"140\" xmlns=\"http://www.w3.org/2000/svg\"", 
    "preserveAspectRatio=\"xMidYMid slice\" focusable=\"false\" role=\"img\" aria-label=\"Placeholder: 140x140\">",
    "<title>Placeholder</title><rect width=\"100%\" height=\"100%\" fill=\"#777\"/><text x=\"50%\" y=\"50%\" fill=\"#777\" dy=\".3em\">140x140</text></svg>",
         "<h2>",Name,"</h2>",
         "<p>",Desc,"</p>",
    "</div><!-- /.col-lg-4 -->"].


init(Req0, Opts) ->
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [layout:content_sol(main(),"Home")], Req0),
    {ok, Req, Opts}.

