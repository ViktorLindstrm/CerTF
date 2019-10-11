%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(fourth_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 

init(Req0, Opts) ->
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of 
               undefined -> 
                   layout:content(challenge(),"Fourth");
               Cert ->
                   PrivDir = code:priv_dir(certf),
                   CertPath = PrivDir++"/ssl/rootCA.crt",
                   {ok,PemBin} = file:read_file(CertPath),
                   PemEntries = public_key:pem_decode(PemBin),
                   {value, CertEntry} = lists:keysearch('Certificate', 1, PemEntries),
                   {_, DerCert, _} = CertEntry,

                   EncCert = public_key:pkix_decode_cert(DerCert,otp),
                   case public_key:pkix_is_issuer(Cert,EncCert) of 
                       true -> 
                           <<"certf{ski_pping_the_validation}">>;
                       _ ->
                           <<"Bad client authentication">>
                   end
           end,
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [<<"<html>">>,Resp,<<"</html>">>], Req0),
    {ok, Req, Opts}.



challenge() -> ["<h2> Challenge 4 </h2>",
     "<p>
     The page requires User authentication through a Client certificate.<br>
      <br>
     Can you use the information gathered from this certificate to gain access to the system?
     </p>"].

find_ski(_,#'Extension'{extnID = Ex}=Out) when Ex == {2,5,29,14} -> 
    Out;
find_ski([_|T],_) -> 
    find_ski(T,hd(T)).


