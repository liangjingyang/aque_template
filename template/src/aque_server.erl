%% Copr. (c) 2013-2015, Simple <ljy0922@gmail.com>

-module(aque_server).

-export([
         start_link/0
        ]).

-export([
         init/1, 
         handle_call/3, 
         handle_cast/2, 
         handle_info/2, 
         terminate/2, 
         code_change/3
        ]).


start_link() -> 
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []). 

init([]) ->
    {ok, []}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_Oldvsn, State, _Extra) ->
    {ok, State}.
