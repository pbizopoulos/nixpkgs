module Main
import System
main : IO ()
main = do
  debug <- getEnv "DEBUG"
  case debug of
    Just "1" => putStrLn "test math ... ok"
    _ => putStrLn "Hello Idris!"
