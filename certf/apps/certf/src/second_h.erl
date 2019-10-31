%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(second_h).

-export([init/2]).
-include_lib("public_key/include/public_key.hrl"). 
-define(Name,"charles").
init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    page(Method,Req0,Opts).

page(<<"POST">>,Req0,Opts) -> 
    {ok, PostVals, Req} = cowboy_req:read_urlencoded_body(Req0),
    Flag = proplists:get_value(<<"flag">>, PostVals),
    Resp = layout:solution("second",Flag,sol()),
    Req2 = cowboy_req:reply(200, #{
            <<"content-type">> => <<"text/html">>
           }, [Resp], Req),
    {ok, Req2, Opts};


page(<<"GET">>,Req0,Opts) -> 
    Cert = cowboy_req:cert(Req0),
    Resp = case Cert of 
        undefined -> 
                   layout:content(challenge(),"Second");
        Cert ->
            EncCert = public_key:pkix_decode_cert(Cert,otp),
            NCert = EncCert#'OTPCertificate'.tbsCertificate,
            Subject = NCert#'OTPTBSCertificate'.subject,
            {rdnSequence,Sub} = Subject,
            NSub = find_subject(Sub),
            case NSub of 
                ?Name -> 
                    <<"CerTF{certified_awesome}">>;
                <<?Name>> -> 
                    <<"CerTF{certified_awesome}">>;
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
    To access this page, we need to know you are the one of our employees that has access to this page, and you will need a client certificate to prove that.<br>
    <i>What does the client certificate validation mean? Maybe it is not the actual certificate that is validated <br>
    Try crafting a certificate that get past the validation checks.</i>
    </p>
     <h3>Emplyees</h3>",
    "<div class=\"row\">",
         create_presos(persons()),
    "</div>"
    ].

find_subject([[{_,_,C}] = H|T]) -> 
    find_subject(T,H,C).

find_subject(_,[{_,{2,5,4,3},{_,B}}],_) -> 
    B;
find_subject([H|T],[{_,_,_}],R) -> 
    find_subject(T,H,R).

persons() -> 
    [{"Ada","Development responsible","#777"},{"Alan","Policy And Compliance","#555"},{"Charles","Something Somewhere","#333"}].

create_presos(L) -> lists:map(fun({Name,Desc,Color}) -> person(Name,Desc,Color) end, L).

person(Name,Desc,Color) -> 
    ["<div class=\"col-lg-4\">",
    "<svg class=\"bd-placeholder-img rounded-circle\" width=\"140\" height=\"140\" xmlns=\"http://www.w3.org/2000/svg\"", 
    "preserveAspectRatio=\"xMidYMid slice\" focusable=\"false\" role=\"img\" aria-label=\"Placeholder: 140x140\">",
    "<title>Placeholder</title><rect width=\"100%\" height=\"100%\" fill=\"",Color,"\"/><text x=\"50%\" y=\"50%\" fill=\"",Color,"\" dy=\".3em\">140x140</text></svg>",
         "<h2>",Name,"</h2>",
         "<p>",Desc,"</p>",
    "</div><!-- /.col-lg-4 -->"].

sol() -> 
    ["<p>Client certificates include an entiy that will be validated, if the certificate itself is not validated it can be easily bypassed</p>"].
