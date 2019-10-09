%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(first_h).

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
	}, [Resp], Req0),
	{ok, Req, Opts}.

challenge() ->
    ["<h2> Challenge 1 </h2>",
     "<p>
     The first Challenge is to find informatinon within the certificate. <br>
     Are you sure you found both of the flags?
    </p>"].

find_subject([[{_,_,C}] = H|T]) -> 
    find_subject(T,H,C).

find_subject(_,[{_,{2,5,4,3},{_,B}}],_) -> 
    B;
find_subject([H|T],[{_,_,_}],R) -> 
    find_subject(T,H,R).

