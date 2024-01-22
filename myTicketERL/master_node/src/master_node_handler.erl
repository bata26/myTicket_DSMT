-module(master_node_handler).
-behaviour(cowboy_rest).

%% Callback Callbacks
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([content_types_provided/2]).
-export([resource_exists/2]).

-export([handle/2, init/2]).

%% Helpes
-import(helper, [get_body/2, get_model/3, reply/3]).

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

content_types_provided(Req, State) ->
    {
        [
            {<<"application/json">>, handle}
            %{<<"json">>, handle}
        ],
        Req,
        State
    }.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, handle}], Req, State}.

resource_exists(Req, State) ->
    {false, Req, State}.

handle(Req, State) ->
    io:format("Handling request in handle/2~n", []),
    {ok, Body, Req2} = cowboy_req:read_body(Req),
    io:format("Body length: ~p~n", [byte_size(Body)]),
    io:format("Received body: ~p~n", [Body]),
    try
        ParsedBody = jiffy:decode(Body),
        io:format("Parsed JSON: ~p~n", [ParsedBody]),
        ResponseBody = jiffy:encode(ParsedBody),

        %{ResponseBody, Req2, State};  % Commenta questa riga se non vuoi ritornare il corpo di risposta
        io:format("Response JSON: ~p~n", [ResponseBody]),
        {ok, Req3} = cowboy_req:reply(
            200, #{<<"content-type">> => <<"application/json">>}, ResponseBody, Req2
        ),
        io:format("Response sent from handle/2~n", []),
        {ok, Req3, State}
    catch
        % Cattura solo le eccezioni Jiffy
        exit:{json, _} ->
            {error, Req2, State};
        Error:Reason ->
            io:format("Error in handle/2: ~p, Reason: ~p~n", [Error, Reason]),
            {error, Req2, State}
    end.
