{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE Trustworthy #-}
{-# OPTIONS_GHC -Wno-safe #-}
{-# OPTIONS_GHC -Wno-trustworthy-safe #-}

module Main (main) where

import Control.Monad (unless)
import System.Environment (lookupEnv)
import System.Exit (exitFailure)
import Test.HUnit
  ( Counts (errors, failures),
    Test (TestCase, TestList),
    assertEqual,
    runTestTT,
    (~:),
  )
import Prelude (IO, Int, Maybe (Just), putStrLn, ($), (+), (==), (>>=))

main :: IO ()
main =
  lookupEnv "DEBUG" >>= \case
    Just "1" -> runTests
    _ -> putStrLn "Hello, World!"

runTests :: IO ()
runTests = do
  counts <- runTestTT tests
  unless (errors counts + failures counts == 0) exitFailure
  where
    tests =
      TestList
        [ "Simple test" ~: TestCase $ assertEqual "1 + 1 is 2" 2 (1 + 1 :: Int)
        ]
