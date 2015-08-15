
-module(atime).

-compile(export_all).

-define(UNIXTIME_BASE, 62167219200).

-include("app.hrl").

get_time_zone() ->
    case application:get_env(?APP_NAME, time_zone) of
        undefined ->
            0;
        {ok, Zone} ->
            Zone
    end.

zone_diff_sec() ->
    0 - get_time_zone() * 3600.

%% seconds
unixtime() ->
    erlang:system_time(seconds).

%% milliseconds
unixtime_milli() ->
    erlang:system_time(milli_seconds).

%% microseconds
unixtime_micro() ->
    erlang:system_time(micro_seconds).

unixtime_nano() ->
    erlang:system_time(nano_seconds).

local_unixtime() ->
    unixtime() + zone_diff_sec().

local_today_zero() ->
    Now = ?MODULE:now(),
    Now - Now rem 86400 + zone_diff_sec().

local_tomorrow_zero() ->
    local_today_zero() + 86400.

datetime_to_unixtime(Date) ->
    calendar:datetime_to_gregorian_seconds(Date) - ?UNIXTIME_BASE.

localtime_to_unixtime(Date) ->
    datetime_to_unixtime(Date) + zone_diff_sec().
