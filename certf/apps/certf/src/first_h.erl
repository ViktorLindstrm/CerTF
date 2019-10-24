%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(first_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(Name,"charles").
init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    logger:debug("Method: ~p~n",[Method]),
    page(Method,Req0,Opts).

page(<<"POST">>,Req0,Opts) -> 
    {ok, PostVals, Req} = cowboy_req:read_urlencoded_body(Req0),
    Flag = proplists:get_value(<<"flag">>, PostVals),
    io:format("~p",[PostVals]),
    Resp = case Flag of 
               <<"CerTF{hidden_deep_within}">> ->
                   solution(hidden_deep_within);
               <<"CerTF{only_a_comment_away}">> ->
                   solution(only_a_comment_away);
               _ -> 
                   solution(false)
    end,
    Req2 = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [Resp], Req),
    {ok, Req2, Opts};


page(<<"GET">>,Req0,Opts) -> 
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
     The first Challenge is to find information within the server certificate. <br>
     This challenge consists of two flags, so make sure to find both of them.
    </p><br>
    <form method=\"post\">
        <input type=\"text\" name=\"flag\" placeholder=\"CerTF{flag}\">
        <button type=\"submit\" class=\"btn btn-primary\">Submit</button>
    </form>
     "].

bad_flag() ->
    ["<h2> Bad Flag </h2>"].

good_flag() ->
    ["<h2> Success! </h2>","
    <p>
    Congratulations! Correct flag!
    </p>
     "
    ].

find_subject([[{_,_,C}] = H|T]) -> 
    find_subject(T,H,C).

find_subject(_,[{_,{2,5,4,3},{_,B}}],_) -> 
    B;
find_subject([H|T],[{_,_,_}],R) -> 
    find_subject(T,H,R).

solution(false) ->
    layout:content(bad_flag(),"First");

solution(hidden_deep_within) -> 
    layout:content(good_flag(),"First").











