
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
-define(DEPS_INCLUDE_DIR, "deps/*/include/").
-define(INCLUDE_DIR, "include/").

get_compile_opts() ->
    AllDir = all_dir(include_dir()) ++ all_dir(deps_include_dir()),
    IncludeDir = lists:map(fun(D) ->
                {i, D}
        end, AllDir),
    IncludeDir ++ 
    [
        {parse_transform, lager_transform},
        {lager_truncation_size, 4096},
        report,
        bin_opt_info,
        warn_obsolete_guard,
        warn_shadow_vars,
        %warnings_as_errors,
        verbose
    ].

%% 禁用的命令
q() ->
    ?UPRINT("WARNING!!! You should never use this command...~n"
        ++ "\"Ctrl + c\" twice to quit this shell.").                         

%% .config file

ucc(Mod) when is_atom(Mod) ->
    ucc(Mod, true).
ucc(Mod, IsUpdate) ->
    case catch aconfig:gen_beam(Mod) of
        ok ->
            case IsUpdate of
                true ->
                    ul(Mod),
                    ?UPRINT("~n====== compile and update complete! ======",[]);
                false ->
                    ?UPRINT("~n====== compile complete! ======",[])
            end;
        Error ->
            Error
    end.
    

%% .erl file
uce(Mod) when is_atom(Mod) ->
   uce(Mod, true).
uce(Mod, IsUpdate) ->
    case catch find_file(atom_to_list(Mod)) of
        [] ->
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
    ?UPRINT("~nupdate module: ~p~nupdate nodes: ~w", [Mods, Nodes]),
    [rpc:call(Node, ?MODULE, uload, [Mods])||Node<-Nodes].

uload([]) -> ok;
uload([Mod | T]) when is_atom(Mod) ->
    case c:l(Mod) of
        {module, _} ->
            uload(T);
        {error, Error} ->
            {Error, Mod}
    end;
uload([FileName | T]) when is_list(FileName) ->
    case filename:extension(FileName) of
        ".beam" ->
            case c:l(list_to_atom(filename:basename(FileName, ".beam"))) of
                {module, _} ->
                    uload(T);
                {error, Error} ->
                    {Error, FileName}
            end;
        _ ->
            {not_beam_file, FileName}
    end.

find_file(Mod) ->
    case filename:extension(Mod) of
        "" ->
            FileName = Mod ++ ".erl";
        ".erl" ->
            FileName = Mod
    end,
    AllDir = all_dir(src_dir()) ++ all_dir(deps_src_dir()),
    find_file2(AllDir, FileName).

find_file2([], _FileName) ->
    [];
find_file2([Dir|AllDir], FileName) -> 
    case filelib:wildcard(Dir ++ "/" ++ FileName) of
        [] ->
            find_file2(AllDir, FileName);
        [File] ->
            {ok, File}
    end.

compile_file(FilePath) ->
    compile_file(FilePath, []).

compile_file(FilePath, OtherOpts) ->
    SrcN = string:str(FilePath, "src"),
    Path = string:substr(FilePath, 1, SrcN - 1),
    Opts = lists:append([[{outdir, Path ++ "ebin"} | get_compile_opts()],OtherOpts]),
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
    case init:get_argument(root_path) of
        {ok, [[Root]]} ->
            Root;
        _ ->
            "."
    end.

src_dir() ->
    get_root_dir() ++ "/" ++ ?SRC_DIR.

deps_src_dir() ->
    get_root_dir() ++ "/" ++ ?DEPS_SRC_DIR.

ebin_dir() ->
    get_root_dir() ++ "/" ++ ?EBIN_DIR.

deps_ebin_dir() ->
    get_root_dir() ++ "/" ++ ?DEPS_EBIN_DIR.

deps_include_dir() ->
    get_root_dir() ++ "/" ++ ?DEPS_INCLUDE_DIR.

include_dir() ->
    get_root_dir() ++ "/" ++ ?INCLUDE_DIR.

all_erl_file() ->
    Files = all_file(src_dir()) ++ all_file(deps_src_dir()),
    [F||F<-Files, filename:extension(F) =:= ".erl"].

all_beam_file() ->
    Files = all_file(ebin_dir()) ++ all_file(deps_ebin_dir()),
    [F||F<-Files, filename:extension(F) =:= ".beam"].

all_dir(Dir) ->
    all_dir2(filelib:wildcard(Dir ++ "/*"), filelib:wildcard(Dir)).

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

