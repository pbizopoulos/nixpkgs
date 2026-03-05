{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase    #-}
{-# LANGUAGE Trustworthy   #-}
{-# OPTIONS_GHC -Wno-safe #-}
{-# OPTIONS_GHC -Wno-trustworthy-safe #-}
module Main (main) where
import           Control.Monad              (unless)
import           Data.Aeson                 (ToJSON, encode)
import qualified Data.ByteString.Lazy.Char8 as BSL
import           GHC.Generics               (Generic)
import           Prelude                    (IO, Int, Maybe (Just), String,
                                             putStrLn, ($), (+), (==), (>>=))
import           System.Environment         (lookupEnv)
import           System.Exit                (exitFailure)
import           Test.HUnit                 (Counts (errors, failures),
                                             Test (TestCase, TestList),
                                             assertEqual, runTestTT, (~:))
data Message = Message {message :: Prelude.String, language :: Prelude.String}
  deriving (Generic)
instance ToJSON Message
main :: IO ()
main =
  lookupEnv "DEBUG" >>= \case
    Just "1" -> runTests
    _ -> do
      putStrLn "Hello, World!"
      let data' = Message "Hello, world!" "Haskell"
      BSL.putStrLn (encode data')
runTests :: IO ()
runTests = do
  counts <- runTestTT tests
  unless (errors counts + failures counts == 0) exitFailure
  where
    tests =
      TestList
        [ "Simple test" ~: TestCase $ assertEqual "1 + 1 is 2" 2 (1 + 1 :: Int)
        ]
