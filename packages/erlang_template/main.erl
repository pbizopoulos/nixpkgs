#!/usr/bin/env escript
main(_) ->
  case os:getenv("DEBUG") of
    "1" ->
      run_tests();
    _ ->
      io:format("Hello Erlang!~n")
  end.
run_tests() ->
  case 1 + 1 of
    2 ->
      io:format("test math ... ok~n");
    _ ->
      io:format("test math failed~n"),
      halt(1)
  end.
