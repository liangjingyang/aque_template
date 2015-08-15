
-module(atime).

-compile(export_all).

-define(UNIXTIME_BASE, 62167219200).

get_time_zone() ->
    case application:get_env(time_zone) of
        undefined ->
            0;
        Zone ->
            Zone
    end.

zone_diff_sec() ->
    0 - get_time_zone() * 3600.

%% seconds
unixtime() ->
    {A, B, _} = erlang:now(),
    A * 1000000 + B.

%% milliseconds
unixtime_milli() ->
    {A, B, C} = erlang:now(),
    A * 1000000000 + B*1000 + C div 1000.

%% microseconds
unixtime_micro() ->
    {A, B, C} = erlang:now(),
    A * 1000000000 + B*1000 + C.

unixtime_nano() ->
    {A, B, C} = erlang:now(),
    A * 1000000000000 + B*1000000 + C.

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
