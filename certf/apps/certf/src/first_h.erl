%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(first_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(Name,"viktor").
init(Req0, Opts) ->
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of 
        undefined -> 
            <<"Sorry, no luck today">>;
        Cert ->
            EncCert = public_key:pkix_decode_cert(Cert,otp),
            NCert = EncCert#'OTPCertificate'.tbsCertificate,
            Subject = NCert#'OTPTBSCertificate'.subject,
            {rdnSequence,Sub} = Subject,
            io:format("Sub ~p~n",[Sub]),
            LSub = erlang:binary_to_list(find_subject(Sub)),
            case LSub of 
                ?Name -> 
                    <<"certif{certified_awesome}">>;
                _ ->
                    <<"close but no cigar">>
            end
                    

    end,
    io:format("Cert: ~p~n",[Resp]),
	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/html">>
	}, [<<"<html>">>,Resp,<<"</html>">>], Req0),
	{ok, Req, Opts}.

find_subject([[{A,B,C}] = H|T]) -> 
    io:format("~p~n",[H]),
    find_subject(T,H,C).
    %find_subject(T,[{A,B,{C1,C2}}],{C1,C2}).

find_subject(_,[{_,{2,5,4,3},{_,B}}],_) -> 
    B;
find_subject([H|T],[{_,_,_}],R) -> 
    find_subject(T,H,R).

