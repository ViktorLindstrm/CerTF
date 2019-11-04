%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(fourth_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    page(Method,Req0,Opts).

page(<<"POST">>,Req0,Opts) -> 
    {ok, PostVals, Req} = cowboy_req:read_urlencoded_body(Req0),
    Flag = proplists:get_value(<<"flag">>, PostVals),
    Resp = layout:solution("fourth", Flag, sol()),
    Req2 = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [Resp], Req),
    {ok, Req2, Opts};


page(<<"GET">>,Req0,Opts) -> 
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
                           <<"CerTF{best_in_pairs}">>;
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
     You have found a folder full with certificates, looks like a lot of certificates used for some testing. 
     <br> Maybe you can find something useful in there with what you can access the page with.<br>
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

sol() -> 
    ["<p>Having certificates just laying around is never a good idea. <br>When
    growing in number it is harder to keep track of what is what and it becomes
    a real issue when environments are mixed or keys re-used. <br>The credentials
    in this case are handled as if they were for testing environments, but
    within those are also production environment keys. <br>But if anyone comes
    looking, as you have proven, it will not take much to find the good parts</p>"].
