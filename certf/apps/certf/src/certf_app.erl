%%%-------------------------------------------------------------------
%% @doc certf public API
%% @end
%%%-------------------------------------------------------------------

-module(certf_app).

-behaviour(application).

-export([start/2, stop/1]).
-include_lib("public_key/include/public_key.hrl"). 

start(_Type, _Args) ->
    logger:debug("~p~n~n",["hello"]),
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", main_h, []},
			{"/first", first_h, []},
			{"/second", second_h, []},
			{"/third", third_h, []}
		]}
	]),
    VerifyFun = {fun(_,{bad_cert, _}, UserState) ->
                         {valid, UserState};
                    (_,{extension, #'Extension'{critical = true}}, UserState) ->
                         {valid, UserState};
                    (_,{extension, _}, UserState) ->
                         {unknown, UserState};
                    (_, valid, UserState) ->
                         {valid, UserState};
                    (_, valid_peer, UserState) ->
                         {valid, UserState}
                 end, []},
	PrivDir = code:priv_dir(certf),
	{ok, _} = cowboy:start_tls(https, [
		{port, 4437},
		{cacertfile, PrivDir ++ "/ssl/rootCA.crt"},
		{certfile, PrivDir ++ "/ssl/server.crt"},
		{keyfile, PrivDir ++ "/ssl/server.key"},
        {verify,verify_peer},
        {verify_fun,VerifyFun}
	], #{env => #{dispatch => Dispatch}}),
	certf_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(https).

%% internal functions
