%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(third_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(SKI, <<172,158,176,147,166,243,167,3,68,12,85,147,251,237,229,120,210,165,205,150>>).

init(Req0, Opts) ->
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of 
               undefined -> 
                   layout:content(challenge(),"Second");
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
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [<<"<html>">>,Resp,<<"</html>">>], Req0),
    {ok, Req, Opts}.


challenge() -> ["<h2> Challenge 3 </h2>",
     "<p>
     The page requires User authentication through a Client certificate.<br>
     You have found what seems to be a valid client certificate from a previous consultant, but upon closer inspection you see that the certificate is expired. <br>
     Can you use the information gathered from this certificate to gain access to the system?
     </p>"].

find_ski(_,#'Extension'{extnID = Ex}=Out) when Ex == {2,5,29,14} -> 
    Out;
find_ski([_|T],_) -> 
    find_ski(T,hd(T)).


