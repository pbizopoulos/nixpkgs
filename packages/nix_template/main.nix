{ debug ? false }:
  let
    tests = if 1 + 1 == 2
      then "test ... ok"
      else throw "test ... failed";
  in if debug
    then tests
    else "Hello Nix!"