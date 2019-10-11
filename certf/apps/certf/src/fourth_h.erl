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
                   RootCert = get_der_crt("rootCA.crt"),
                   SKI = get_ski_from_crt("chal4.crt"),
                   InputSKI = get_ski(Cert),
                   EncCert = public_key:pkix_decode_cert(RootCert,otp),
                   case public_key:pkix_is_issuer(Cert,EncCert) and (InputSKI == SKI) of 
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
     You have found a folder full with certificates,
     <br> see if you find anything usefull in there with what you can access the page with.<br>
     <br>
     <code> <a href=/chal4.tar.gz>folder</a> </code>
     </p>"].

find_ski(_,#'Extension'{extnID = Ex}=Out) when Ex == {2,5,29,14} -> 
    Out;
find_ski([_|T],_) -> 
    find_ski(T,hd(T)).

get_ski(Cert) -> 
    EncCert = public_key:pkix_decode_cert(Cert,otp),
    NCert = EncCert#'OTPCertificate'.tbsCertificate,
    Extensions = NCert#'OTPTBSCertificate'.extensions,
    {_,_,_,SKI} = find_ski(Extensions,hd(Extensions)),
    SKI.

get_der_crt(Name) -> 
	PrivDir = code:priv_dir(certf),
    CertPath = PrivDir++"/ssl/"++Name,
    {ok,PemBin} = file:read_file(CertPath),
    PemEntries = public_key:pem_decode(PemBin),
    {value, CertEntry} = lists:keysearch('Certificate', 1, PemEntries),
    {_, DerCert, _} = CertEntry,
    DerCert.

get_ski_from_crt(Name) -> 
    DerCert = get_der_crt(Name),
    get_ski(DerCert).

