%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(second_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(Name,"charles").
init(Req0, Opts) ->
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of 
        undefined -> 
                   layout:content(challenge(),"First");
        Cert ->
            EncCert = public_key:pkix_decode_cert(Cert,otp),
            NCert = EncCert#'OTPCertificate'.tbsCertificate,
            Subject = NCert#'OTPTBSCertificate'.subject,
            {rdnSequence,Sub} = Subject,
            NSub = find_subject(Sub),
            case NSub of 
                ?Name -> 
                    <<"certif{certified_awesome}">>;
                <<?Name>> -> 
                    <<"certif{certified_awesome}">>;
                _ ->
                    <<"Bad Client authentication">>
            end
    end,
	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/html">>
	}, [<<"<html>">>,Resp,<<"</html>">>], Req0),
	{ok, Req, Opts}.

challenge() ->
    ["<h2> Challenge 2 </h2>",
     "<p>
    The page requires User authentication through a Client certificate.<br>
    What if the client validation is not sufficient? <br>
    Maybe there is a way of trick the system to think you are someone you are not.<br> Try crafting a certificate that get past the validation checks.
    </p>"].

find_subject([[{_,_,C}] = H|T]) -> 
    find_subject(T,H,C).

find_subject(_,[{_,{2,5,4,3},{_,B}}],_) -> 
    B;
find_subject([H|T],[{_,_,_}],R) -> 
    find_subject(T,H,R).

