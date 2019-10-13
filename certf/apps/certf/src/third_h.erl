%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(third_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 

init(Req0, Opts) ->
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of 
               undefined -> 
                   layout:content(challenge(),"Third");
               Cert ->
                   EncCert = public_key:pkix_decode_cert(Cert,otp),
                   NCert = EncCert#'OTPCertificate'.tbsCertificate,
                   Extensions = NCert#'OTPTBSCertificate'.extensions,
                   SKI = find_ski(Extensions,hd(Extensions)),
                   Consult_SKI = get_ski_from_crt("consult.crt"),
                   case SKI#'Extension'.extnValue of 
                       Consult_SKI -> 
                           <<"certf{ski_pping_the_validation}">>;
                       _ ->
                           <<"Bad client authentication">>
                   end
           end,
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [<<"<html>">>,Resp,<<"</html>">>], Req0),
    {ok, Req, Opts}.

get_ski_from_crt(Name) -> 
	PrivDir = code:priv_dir(certf),
    CertPath = PrivDir++"/ssl/"++Name,
    {ok,PemBin} = file:read_file(CertPath),
    PemEntries = public_key:pem_decode(PemBin),
    {value, CertEntry} = lists:keysearch('Certificate', 1, PemEntries),
    {_, DerCert, _} = CertEntry,
    EncCert = public_key:pkix_decode_cert(DerCert,otp),
    NCert = EncCert#'OTPCertificate'.tbsCertificate,
    Extensions = NCert#'OTPTBSCertificate'.extensions,
    {_,_,_,SKI} = find_ski(Extensions,hd(Extensions)),
    SKI.

get_consulut_crt() -> 
	PrivDir = code:priv_dir(certf),
    CertPath = PrivDir++"/ssl/consult.crt",
    {ok,Cert} = file:read_file(CertPath),
    HCert = binary:replace(Cert,<<"\n">>,<<"<br>">>,[global]),
    ["<code>",HCert,"</code>"].


challenge() -> ["<h2> Challenge 3 </h2>",
     "<p>
     The page requires User authentication through a Client certificate. And
     this time, we have made sure not to be as trivial as the previous
     challenge. State of the art, Pinning! <br>
      <br>
     <i>You have found a certificate that you know works, but you don't have the key. 
     Can you use the information gathered from this certificate to gain access to the system? <br>
     Pinning, but what has they pinned on?
     </i></p>",get_consulut_crt()].

find_ski(_,#'Extension'{extnID = Ex}=Out) when Ex == {2,5,29,14} -> 
    Out;
find_ski([_|T],_) -> 
    find_ski(T,hd(T)).


