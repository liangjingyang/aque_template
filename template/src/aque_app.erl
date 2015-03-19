%% Copr. (c) 2013-2015, Liangjingyang <simple.continue@gmail.com>

-module(aque_app).

-export([
         start/0,
         stop/0,

         start/2,
         stop/1
        ]).

-define(APPNAME, aque).

start() ->
    lager:start(),
    application:start(?APPNAME),
    lager:info(lists:concat([?APPNAME, " start!"])),
    ok.

stop() ->
    application:stop(?APPNAME),
    timer:sleep(1000),
    erlang:halt(0).

start(_Type, _Args) ->
    aque_sup:start_link().

stop(_State) ->
    ok.
