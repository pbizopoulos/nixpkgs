{-# LANGUAGE LambdaCase #-}
module Main (main) where
import           System.Environment (lookupEnv)
main :: IO ()
main =
  lookupEnv "DEBUG" >>= \case
    Just "1" -> putStrLn "test ... ok"
    _ -> mapM_ (putStrLn . fizzbuzz) [1 .. 100]
fizzbuzz :: Int -> String
fizzbuzz i
  | i `rem` 15 == 0 = red ++ "FizzBuzz" ++ reset
  | i `rem` 3 == 0 = green ++ "Fizz" ++ reset
  | i `rem` 5 == 0 = blue ++ "Buzz" ++ reset
  | otherwise = show i
  where
    red = "\x1b[31m"
    green = "\x1b[32m"
    blue = "\x1b[34m"
    reset = "\x1b[0m"
