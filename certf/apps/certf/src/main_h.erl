%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(main_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(Name,"viktor").
init(Req0, Opts) ->
    Resp = <<"<h1>Certification For Everyone</h1>
    <p>Our company aims to provide certification for everyone!</p>
    <p>The company is run by three persons, <br>
    Ada, Developent responsible<br>
    Alan, Policy and compliance officer<br>
    Charles, Data privacy officer, because GDPR everywhere<br>
    </p>
    
    <ul>
    <li><a href=\"/first\"> first -> CN /missing validation</a></li>
    <li><a href=\"/second\"> second -> invalid with valid SKI /pinning</a></li>
    <li>third -> invalid chain validation (issuer, not AKI-SKI)</li>
    <li>fourth -> policy not validated (ServerCA issuing client certs)</li>
             </ul> ">>,
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [<<"<html>">>,Resp,<<"</html>">>], Req0),
    {ok, Req, Opts}.

