%%%-------------------------------------------------------------------
%% @doc myTicketERL top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(worker_node_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

%-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
	% Supervisor parameters
	SupFlags = #{strategy => one_for_one,
				 intensity => 1,
				 period => 60},
	% Specs for child processes
	CowboyListener = #{id => cowboy_listener, % child process name
						start => {cowboy_listener, start_link, []}, % function that will be executed
						restart => permanent}, % always restart when crashes
	ChildSpecs = [CowboyListener],
    %ChildSpecs = [],
	% Return value
	{ok, {SupFlags, ChildSpecs}}.


%% internal functions
