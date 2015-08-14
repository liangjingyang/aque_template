
-module(user_default).

-compile(export_all).

-include_lib("kernel/include/file.hrl").

-define(UPRINT(Format),
    io:format(Format++"~n", [])).
-define(UPRINT(Format, Args),
    io:format(Format++"~n", Args)).

-define(EBIN_DIR, "ebin/").
-define(DEPS_EBIN_DIR, "deps/*/ebin/").
-define(SRC_DIR, "src/").
-define(DEPS_SRC_DIR, "deps/*/src/").

-define(NONE, none).
-define(COMPILE_OPT, 
    [
        {i, ""},
        {i, "include"},
        {i, "deps/*/include"},
        {i, "deps/*/src"},
        {i, "src"},
        {i, "src/*"},
        {i, "src/*/*"},
        {parse_transform, lager_transform},
        {lager_truncation_size, 4096},
        report,
        bin_opt_info,
        warn_obsolete_guard,
        warn_shadow_vars,
        %warnings_as_errors,
        verbose
    ]
    ).

%% 禁用的命令
q() ->
    ?UPRINT("WARNING!!! You should never use this command...~n"
        ++ "\"Ctrl + c\" twice to quit this shell.").                         

%% .config file

ucc(Mod) when is_atom(Mod) ->
    ucc(Mod, true).
ucc(Mod, IsUpdate) ->
    aconfig:gen_beam(Mod),
    case IsUpdate of
        true ->
            ul(Mod),
            ?UPRINT("~n====== compile and update complete! ======",[]);
        false ->
            ?UPRINT("~n====== compile complete! ======",[])
    end.

%% .erl file
uce(Mod) when is_atom(Mod) ->
   uce(Mod, true).
uce(Mod, IsUpdate) ->
    case catch find_file(atom_to_list(Mod)) of
        ?NONE ->
            {error, {no_mod, Mod}};
        {ok, FilePath} ->
            ?UPRINT("~ncompiling:~s", [FilePath]),
            compile_file(FilePath),
            case IsUpdate of
                true ->
                    ul(Mod),
                    ?UPRINT("~n====== compile and update complete! ======",[]);
                false ->
                    ?UPRINT("~n====== compile complete! ======",[])
            end,
            ok

    end.

ul() ->
    ul(all_beam_file()).
ul(Mod) when is_atom(Mod) ->
    ul([Mod]);
ul(Mods) ->
    Nodes = [node()|nodes()],
    ?UPRINT("~nupdate module: ~w~nupdate nodes: ~w", [Mods, Nodes]),
    [rpc:call(Node, ?MODULE, uload, [Mods])||Node<-Nodes].

uload([]) -> ok;
uload([FileName | T]) ->
    case filename:extension(FileName) of
        ".beam" ->
            case c:l(filename:basename(FileName, ".beam")) of
                {module, _} ->
                    uload(T);
                {error, Error} ->
                    {Error, FileName}
            end;
        _ ->
            uload(T)
    end.

find_file(Mod) ->
    FileName =
    case filename:extension(Mod) of
        "" ->
            Mod ++ ".erl";
        ".erl" ->
            Mod
    end,
    % 寻找模块
    [
        begin
                case filelib:wildcard(Dir ++ "/" ++ FileName) of
                    [] ->
                        ok;
                    [File] ->
                        throw({ok, File})
                end
        end 
        || Dir <- [all_dir(src_dir()) ++ all_dir(deps_src_dir())]
    ],
    ?NONE.

compile_file(FilePath) ->
    compile_file(FilePath, []).

compile_file(FilePath, OtherOpts) ->
    SrcN = string:str(FilePath, "src"),
    Path = string:substr(FilePath, 1, SrcN - 1),
    Opts = lists:append([[{outdir, Path ++ "ebin"} | ?COMPILE_OPT],OtherOpts]),
    case compile:file(FilePath, Opts) of
        {ok, _Data} ->
            ?UPRINT("compile succ:~p!", [_Data]),
            ok;
        {ok, _, Warnings} ->
            ?UPRINT("compile succ!", []),
            ?UPRINT("warnings:~n~p", [Warnings]),
            ok;
        error ->
            throw({error, {compile_failed, FilePath}});
        {error, Errors, Warnings} ->
            throw({error, {compile_failed, FilePath, {error, Errors}, {warnings, Warnings}}})
    end.

   
get_root_dir() ->
    {ok, [[Root]]} = init:get_argument(root_path),
    Root.

src_dir() ->
    get_root_dir() ++ "/" ++ ?SRC_DIR.

deps_src_dir() ->
    get_root_dir() ++ "/" ++ ?DEPS_SRC_DIR.

ebin_dir() ->
    get_root_dir() ++ "/" ++ ?EBIN_DIR.

deps_ebin_dir() ->
    get_root_dir() ++ "/" ++ ?DEPS_EBIN_DIR.

all_erl_file() ->
    Files = all_file(src_dir()) ++ all_file(deps_src_dir()),
    [F||F<-Files, filename:extension(F) =:= ".erl"].

all_beam_file() ->
    Files = all_file(ebin_dir()) ++ all_file(deps_ebin_dir()),
    [F||F<-Files, filename:extension(F) =:= ".beam"].

all_dir(Dir) ->
    all_dir2(filelib:wildcard(Dir ++ "/*"), [Dir]).

all_dir2([], Acc) ->
    Acc;

all_dir2([Dir|DirList], Acc) ->
    case filelib:is_dir(Dir) of
        true ->
            Acc2 = all_dir(Dir) ++ Acc;
        false ->
            Acc2 = Acc
    end,
    all_dir2(DirList, Acc2).

all_file(Dir) ->
    all_file2(filelib:wildcard(Dir ++ "/*"), []).

all_file2([], Acc) ->
    Acc;

all_file2([File|FileList], Acc) ->
    case filelib:is_dir(File) of
        true ->
            Acc2 = all_file(File) ++ Acc;
        false ->
            Acc2 = [File|Acc]
    end,
    all_file2(FileList, Acc2).

