%% Listing 4.3 on page 126
-module(erl34_sup).
-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    Server = {erl34_server, {erl34_server, start_link, []},
             permanent, 2000, worker, [erl34_server]},
    {ok, {{one_for_one, 0, 1}, [Server]}}.
