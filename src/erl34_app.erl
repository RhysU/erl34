%% Listing 4.2 on page 124
-module(erl34_app).
-behavior(application).

-export([ start/2, stop/1 ]).

start(_Type, _StartArgs) ->
    case erl34_sup:start_link() of
        {ok, Pid} ->
            {ok, Pid};
        Other ->
            {error, Other}
    end.

stop(_State) ->
    ok.
