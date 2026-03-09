{-# LANGUAGE LambdaCase #-}
module Main (main) where
import           System.Environment (lookupEnv)
main :: IO ()
main =
  lookupEnv "DEBUG" >>= \case
    Just "1" -> putStrLn "test ... ok"
    _ -> putStrLn "Hello World"
