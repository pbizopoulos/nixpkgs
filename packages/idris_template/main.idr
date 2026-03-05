module Main
import System
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
    _ => putStrLn "Hello Idris!"
