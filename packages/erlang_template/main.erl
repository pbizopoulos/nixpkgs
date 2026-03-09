#!/usr/bin/env escript
run_tests() ->
    case 1 + 1 =:= 2 of
        true ->
            io:format("test ... ok~n");
        false ->
            io:format("test math failed~n"),
            halt(1)
    end.
main(_) ->
    case os:getenv("DEBUG") of
        "1" ->
            run_tests();
        _ ->
            io:format("Hello World~n")
    end.
