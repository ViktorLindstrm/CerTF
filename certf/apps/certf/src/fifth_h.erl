%% Feel free to use, reuse and abuse the code in this file.

-module(fifth_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    page(Method,Req0,Opts).

page(<<"POST">>,Req0,Opts) ->
    {ok, PostVals, Req} = cowboy_req:read_urlencoded_body(Req0),
    Flag = proplists:get_value(<<"flag">>, PostVals),
    Resp = layout:solution("fifth",Flag,sol()),
    Req2 = cowboy_req:reply(200, #{
             <<"content-type">> => <<"text/html">>
            }, [Resp], Req),
    {ok, Req2, Opts};


page(<<"GET">>,Req0,Opts) ->
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of
               undefined ->
                   layout:content(challenge(),"Fifth");
               Cert ->
                   EncCert = public_key:pkix_decode_cert(Cert,otp),
                   NCert = EncCert#'OTPCertificate'.tbsCertificate,
                   Issuer = NCert#'OTPTBSCertificate'.issuer,
                   case term_to_binary(Issuer) == get_issuer_from_file("rootCA.crt") of
                       true ->
                           <<"CerTF{issued_in_vain}">>;
                       _ ->
                           <<"Bad client authentication">>
                   end
           end,
    Req = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [<<"<html>">>,Resp,<<"</html>">>], Req0),
    {ok, Req, Opts}.

get_issuer_from_file(Name) ->
    PrivDir = code:priv_dir(certf),
    CertPath = PrivDir++"/ssl/"++Name,
    {ok,PemBin} = file:read_file(CertPath),
    PemEntries = public_key:pem_decode(PemBin),
    {value, CertEntry} = lists:keysearch('Certificate', 1, PemEntries),
    {_, DerCert, _} = CertEntry,
    EncCert = public_key:pkix_decode_cert(DerCert,otp),
    NCert = EncCert#'OTPCertificate'.tbsCertificate,
    Issuer = NCert#'OTPTBSCertificate'.issuer,
    term_to_binary(Issuer).

challenge() -> ["<h2> Challenge 5 </h2>",
                "<p>
     The page requires User authentication through a Client certificate. And
     this time, we have made sure not to be as trivial as the previous
     challenge. No pinning this time, but it will have to be trusted by the Issuer <br>
      <br>
     </p>"].



sol() -> ["<p>Only validating the issuer field within the certificate is not
enough to be sure that the certificate actually is issued by said issuer. As
you have proven, this can with ease be forged. <br> Many misconceptions around
certificates exists and it can (and has been) easily be validated in a way that
the validation is insufficient and allows for an unauthorized person to gain
access. <br> One example of this is: 
<a href=\"https://sec-consult.com/en/blog/2019/10/vulnerability-in-eu-cross-border-authentication-software-eidas-node/\">Vulnerabilityin EU cross-border authentication software (eIDAS Node)</a>"].



