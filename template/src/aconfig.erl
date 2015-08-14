
-module(aconfig).

-export([init/0, reload_all/0, reload/1, list/1, find/2]).
-export([gen_beam/1, gen_all_beam/0]).

-define(FOREACH(Fun, List), 
    lists:foreach(fun(E)-> 
                Fun(E) end, 
        List)).

%% FileType: record_consult, key_value_consult, key_value_list, record_list
%% KeyType: set, bag

-define(CONFIG_FILE_LIST,[    
        %{c_hero_lv, "c_hero_lv.config", record_consult, set}
    ]).


init()->
    reload_all(),
    ok.

reload_all()->    
    ?FOREACH(catch_do_load_config, ?CONFIG_FILE_LIST),
    ok.

gen_all_beam() ->
    ?FOREACH(do_gen_beam, ?CONFIG_FILE_LIST),
    ok.

gen_beam(ConfigName) ->
    case lists:keyfind(ConfigName, 1, ?CONFIG_FILE_LIST) of
        false->
            {error, not_found};
        ConfRec->
            do_gen_beam(ConfRec),
            ok
    end.

reload(ConfigName) when is_atom(ConfigName)->
    case lists:keyfind(ConfigName, 1, ?CONFIG_FILE_LIST) of
        false->
            {error, not_found};
        ConfRec->
            catch_do_load_config(ConfRec),
            ok
    end.

list(ConfigName)->
    case do_list(ConfigName) of
        undefined -> 
            [];
        not_implement -> 
            [];
        Val -> 
            Val
    end.

find(ConfigName, Key)->
    case do_find(ConfigName,Key) of
        undefined -> 
            [];
        not_implement -> 
            [];
        Val -> 
            [Val]
    end.

%% ====================================================================
%% Local Functions
%% ====================================================================

do_list(ConfigName) ->
    ConfigName:list().

do_find(ConfigName,Key) ->
    ConfigName:find_by_key(Key).

get_root_dir() ->
    {ok, [[Root]]} = init:get_argument(root_path),
    Root.

get_config_dir() ->
    get_root_dir() ++ "/config/".

do_gen_beam({Name, _, _} = ConfRec) ->
    {ok, Code} = catch_do_load_config(ConfRec),
    FileName = lists:concat([get_root_dir(), "/ebin/", Name , ".beam"]),
    file:write_file(FileName, Code, [write, binary]),
    ok.

catch_do_load_config(ConfRec) ->
    {Name, Path, FileType, KeyType} = ConfRec,
    ConfRec2 = {Name, get_config_dir() ++ Path, FileType, KeyType},
    try
        do_load_config(ConfRec2)
    catch
        _Error:Reason->
            io:format("Reason:~w, Name:~w, Path:~w, FileType:~w, KeyType:~w~n",
                [Reason, Name, Path, FileType, KeyType])
    end.

do_load_config({Name, FilePath, record_consult, KeyType}) ->
    {ok, RecList} = file:consult(FilePath),
    KeyValues = [ begin
                Key = element(2, Rec), {Key, Rec}
        end || Rec <- RecList ],
    do_load_gen_src(Name, KeyType, KeyValues, RecList);

do_load_config({Name, FilePath, record_list, KeyType}) ->
    {ok, [RecList]} = file:consult(FilePath),
    KeyValues = [ begin
                Key = element(2, Rec), {Key, Rec}
        end || Rec <- RecList ],
    do_load_gen_src(Name, KeyType, KeyValues, RecList);

do_load_config({Name, FilePath, key_value_consult, KeyType})->
    {ok, RecList} = file:consult(FilePath),
    do_load_gen_src(Name, KeyType, RecList, RecList);

do_load_config({Name, FilePath, key_value_list, KeyType})->
    {ok, [RecList]} = file:consult(FilePath),
    do_load_gen_src(Name, KeyType, RecList, RecList).

do_load_gen_src(Name, KeyType, KeyValues, ValList)->
    try
        Src = gen_src(Name, KeyType, KeyValues, ValList),
        {Mod, Code} = dynamic_compile:from_string(Src),
        code:load_binary(Mod, misc:to_list(Name) ++ ".erl", Code),
        {ok, Code}
    catch
        _Error:Reason -> 
            Trace = erlang:get_stacktrace(), 
            io:format("Name:~w, KeyType:~w, Reason=~w, Trace=~w~n", 
                [Name, KeyType, Reason, Trace])
    end.

gen_src(Name, KeyType, KeyValues, ValList) ->
    case KeyType of
        bag ->
            KeyValues2 = lists:foldl(fun({K, V}, Acc) ->
                        case lists:keyfind(K, 1, Acc) of
                            false ->
                                [{K, [V]}|Acc];
                            {K, VO} ->
                                [{K, [V|VO]}|lists:keydelete(K, 1, Acc)]
                        end
                end, [], KeyValues);
        set ->
            KeyValues2 = KeyValues
    end,
    Cases = lists:foldl(fun({Key, Value}, C) ->
                lists:concat([C, lists:flatten(io_lib:format("find_by_key(~w) -> ~w;\n", [Key, Value]))])
        end,
        "",
        KeyValues2),

    StrList = lists:flatten(io_lib:format("     ~w\n", [ValList])),

    "-module(" ++ 
    misc:to_list(Name) ++ 
    ").\n" ++ 
    "-export([list/0,find_by_key/1]).\n" ++ 
    "list()->" ++ 
    StrList ++
    ".\n\n" ++ 
    Cases ++
    "find_by_key(_Key) -> undefined.".

