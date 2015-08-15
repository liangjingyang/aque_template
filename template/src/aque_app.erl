%% Copr. (c) 2013-2015, Liangjingyang <simple.continue@gmail.com>

-module(aque_app).

-export([
         start/0,
         stop/0,

         start/2,
         stop/1
        ]).

-include("app.hrl").

start() ->
    lager:start(),
    application:start(?APP_NAME),
    lager:info(lists:concat([?APP_NAME, " start!"])),
    ok.

stop() ->
    application:stop(?APP_NAME),
    timer:sleep(1000),
    erlang:halt(0).

start(_Type, _Args) ->
    aconfig:init(),
    aque_sup:start_link().

stop(_State) ->
    ok.
