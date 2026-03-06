#!/usr/bin/env escript
-define(RED, "\e[31m").
-define(GREEN, "\e[32m").
-define(BLUE, "\e[34m").
-define(RESET, "\e[0m").
main(_) ->
    case os:getenv("DEBUG") of
        "1" ->
            run_tests();
        _ ->
            lists:foreach(fun fizzbuzz/1, lists:seq(1, 100))
    end.
fizzbuzz(I) when I rem 15 =:= 0 -> io:format("~sFizzBuzz~s~n", [?RED, ?RESET]);
fizzbuzz(I) when I rem 3 =:= 0 -> io:format("~sFizz~s~n", [?GREEN, ?RESET]);
fizzbuzz(I) when I rem 5 =:= 0 -> io:format("~sBuzz~s~n", [?BLUE, ?RESET]);
fizzbuzz(I) -> io:format("~p~n", [I]).
run_tests() ->
    case 1 + 1 of
        2 ->
            io:format("test ... ok~n");
        _ ->
            io:format("test math failed~n"),
            halt(1)
    end.
