-module(erl34_server).
-behaviour(gen_server).

%% API (Listing 3.2 on page 103)
-export([ start_link/1, start_link/0, get_count/0, stop/0 ]).

%% gen_server callbacks (Listing 3.2 on page 103)
-export([ init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3 ]).

%% EUnit for unit testing (Section 3.4 on page 117)
-include_lib("eunit/include/eunit.hrl").

-define(SERVER, ?MODULE).
-define(DEFAULT_PORT, 1055).

%% API (Listing 3.2 on page 103)
start_link() ->
    start_link(?DEFAULT_PORT).

start_link(Port) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Port], []).

get_count() ->
    gen_server:call(?SERVER, get_count).

stop() ->
    gen_server:cast(?SERVER, stop).

-record(state, {port, lsock, request_count = 0}).

%% gen_server callbacks (Listing 3.4 on page 110)
init([Port]) ->
    {ok, LSock} = gen_tcp:listen(Port, [{active, true}]),
    {ok, #state{port = Port, lsock = LSock}, 0}.

handle_call(get_count, _From, State) ->
    {reply, {ok, State#state.request_count}, State}.

handle_cast(stop, State) ->
     {stop, normal, State}.

%% gen_server callbacks (Listing 3.5 on page 113)
handle_info({tcp, Socket, RawData}, State) ->
    do_rpc(Socket, RawData),
    RequestCount = State#state.request_count,
    {noreply, State#state{request_count = RequestCount + 1}};
handle_info(timeout, #state{lsock = LSock} = State) ->
    {ok, _Sock} = gen_tcp:accept(LSock),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal (Modified Listing 3.6 on page 114)
do_rpc(Socket, RawData) ->
    try
        {M, F, A} = parse_mfa(RawData),
        gen_tcp:send(Socket, io_lib:fwrite("~p~n", [apply(M, F, A)]))
    catch
        _Class:Err ->
            gen_tcp:send(Socket, io_lib:fwrite("~p~n", [Err]))
    end.

parse_mfa(Code) ->
    {ok, Tokens, _} = erl_scan:string(Code),
    {ok, [Form]} = erl_parse:parse_exprs(Tokens),
    {call, 1, {remote, 1, {atom, 1, Module}, {atom, 1, Function}}, Args} = Form,
    {Module, Function, lists:map(fun({_,1,Arg}) -> Arg end, Args)}.

parse_mfa_test() ->
    {armagideon,time,[clash,1979]} = parse_mfa("armagideon:time(clash, 1979).").
