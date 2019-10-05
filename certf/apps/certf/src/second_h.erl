%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(second_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(SKI, <<172,158,176,147,166,243,167,3,68,12,85,147,251,237,229,120,210,165,205,150>>).
init(Req0, Opts) ->
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of 
               undefined -> 
                   <<"Client authentication needed">>;
               Cert ->
                   EncCert = public_key:pkix_decode_cert(Cert,otp),
                   NCert = EncCert#'OTPCertificate'.tbsCertificate,
                   Extensions = NCert#'OTPTBSCertificate'.extensions,
                   SKI = find_ski(Extensions,hd(Extensions)),
                   case SKI#'Extension'.extnValue of 
                       ?SKI -> 
                           <<"certf{ski_pping_the_validation}">>;
                       _ ->
                           <<"Bad client authentication">>
                   end
           end,
    io:format("Cert: ~p~n",[Resp]),
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [<<"<html>">>,Resp,<<"</html>">>], Req0),
    {ok, Req, Opts}.

find_ski(_,#'Extension'{extnID = Ex}=Out) when Ex == {2,5,29,14} -> 
    Out;
find_ski([_|T],_) -> 
    find_ski(T,hd(T)).


