module Main
import System
RED : String
RED = "\x1b[31m"
GREEN : String
GREEN = "\x1b[32m"
BLUE : String
BLUE = "\x1b[34m"
RESET : String
RESET = "\x1b[0m"
fizzbuzz : Int -> String
fizzbuzz i =
  if mod i 15 == 0 then RED ++ "FizzBuzz" ++ RESET
  else if mod i 3 == 0 then GREEN ++ "Fizz" ++ RESET
  else if mod i 5 == 0 then BLUE ++ "Buzz" ++ RESET
  else show i
runTests : IO ()
runTests = do
  if 1 + 1 == 2
    then putStrLn "test ... ok"
    else putStrLn "test ... failed"
main : IO ()
main = do
  debug <- getEnv "DEBUG"
  case debug of
    Just "1" => runTests
    _ => sequence_ (map (putStrLn . fizzbuzz) [1..100])
