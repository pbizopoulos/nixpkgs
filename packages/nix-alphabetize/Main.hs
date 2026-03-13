{-# LANGUAGE StandaloneKindSignatures #-}
{-# LANGUAGE Trustworthy              #-}
{-# OPTIONS_GHC -Wno-unsafe -Wno-prepositive-qualified-module #-}
module Main (main) where
import           Control.Monad             (void)
import           Data.Fix                  (Fix (Fix))
import           Data.Function             (on)
import           Data.Functor              (Functor (fmap))
import           Data.Functor.Compose      (Compose (Compose))
import           Data.Kind                 (Type)
import           Data.List                 (break, groupBy, sortBy)
import           Data.List.NonEmpty        (NonEmpty ((:|)))
import           Data.Ord                  (comparing)
import           Data.Text                 (Text, drop, empty, isInfixOf,
                                            isPrefixOf, length, lines, pack,
                                            strip, stripStart, takeWhile,
                                            uncons, unlines)
import           Data.Text.IO              (readFile, writeFile)
import           Nix.Expr.Types            (Antiquoted (Plain),
                                            Binding (NamedVar),
                                            NExprF (NAbs, NLet, NList, NSet),
                                            NKeyName (DynamicKey, StaticKey),
                                            NPos (NPos), NString (DoubleQuoted),
                                            Params (ParamSet),
                                            Recursivity (NonRecursive),
                                            VarName (VarName), getSourceLine)
import           Nix.Expr.Types.Annotated  (AnnUnit (AnnUnit), NExprLoc,
                                            SrcSpan (SrcSpan), stripAnnotation)
import           Nix.Parser                (parseNixFileLoc)
import           Nix.Pretty                (prettyNix)
import           Nix.Utils                 (Path (Path))
import           Prelude                   (Bool (False), Either (Left, Right),
                                            Eq ((==)), FilePath, IO, Int,
                                            Maybe (Just, Nothing), Show (show),
                                            String, any, concatMap, elem, fst,
                                            map, mapM_, null, otherwise,
                                            putStrLn, zip, ($), (&&), (++), (.),
                                            (/=), (<>), (||))
import           Prettyprinter             (LayoutOptions (LayoutOptions),
                                            PageWidth (AvailablePerLine),
                                            layoutPretty)
import           Prettyprinter.Render.Text (renderStrict)
import           System.Environment        (getArgs)
import           System.IO                 (hClose)
import           System.IO.Temp            (withSystemTempFile)
import           Test.HUnit                (Test (TestCase, TestList),
                                            assertEqual, assertFailure,
                                            runTestTT)
import           Text.Megaparsec.Pos       (unPos)
main :: IO ()
main = do
  args <- getArgs
  if null args || args == ["--test"]
    then void $ runTestTT getAllFormattingTests
    else
      mapM_
        ( \filePath -> do
            parseResult <- parseNixFileLoc (Path filePath)
            case parseResult of
              Left parseError -> putStrLn ("Error parsing " ++ filePath ++ ": " ++ show parseError)
              Right expr -> writeFormattedFile filePath expr
        )
        args
writeFormattedFile :: FilePath -> NExprLoc -> IO ()
writeFormattedFile filePath expr = do
  fileContent <- readFile filePath
  let ignoreLines = getIgnoreLineNumbers fileContent
      ignoreBindings = getIgnoreBindingKeys fileContent
      sortedExpr = sortExpression ignoreLines expr
      finalText =
        addIgnoreMarkers ignoreBindings $
          renderStrict $
            layoutPretty (LayoutOptions (AvailablePerLine 1 1.0)) $
              prettyNix $
                stripAnnotation sortedExpr
  writeFile filePath finalText
renderExpressionText :: NExprLoc -> Text
renderExpressionText =
  renderStrict . layoutPretty (LayoutOptions (AvailablePerLine 1 1.0)) . prettyNix . stripAnnotation
ignoreMarker :: Text
ignoreMarker = pack "nix-alphabetize-ignore"
getIgnoreLineNumbers :: Text -> [Int]
getIgnoreLineNumbers fileContent =
  [ lineNumber
  | (lineNumber, lineText) <- zip [1 ..] (lines fileContent),
    ignoreMarker `isInfixOf` lineText
  ]
getIgnoreBindingKeys :: Text -> [Text]
getIgnoreBindingKeys fileContent =
  [ key
  | lineText <- lines fileContent,
    ignoreMarker `isInfixOf` lineText,
    let key = strip (takeWhile (/= '=') lineText),
    key /= empty
  ]
addIgnoreMarkers :: [Text] -> Text -> Text
addIgnoreMarkers [] content = content
addIgnoreMarkers ignoreBindings content =
  unlines (map (addIgnoreMarkerLine ignoreBindings) (lines content))
addIgnoreMarkerLine :: [Text] -> Text -> Text
addIgnoreMarkerLine ignoreBindings lineText
  | ignoreMarker `isInfixOf` lineText = lineText
  | any (`matchesBindingLine` stripStart lineText) ignoreBindings =
      lineText <> pack " # nix-alphabetize-ignore"
  | otherwise = lineText
matchesBindingLine :: Text -> Text -> Bool
matchesBindingLine key trimmedLine =
  key `isPrefixOf` trimmedLine
    && case uncons (drop (length key) trimmedLine) of
      Just (nextChar, _) -> nextChar == ' ' || nextChar == '='
      Nothing            -> False
bindingLineNumber :: Binding NExprLoc -> Maybe Int
bindingLineNumber (NamedVar _ _ bindingPos) =
  Just
    ( case getSourceLine bindingPos of
        NPos pos -> unPos pos
    )
bindingLineNumber _ = Nothing
isIgnoredBinding :: [Int] -> Binding NExprLoc -> Bool
isIgnoredBinding ignoreLines binding =
  case bindingLineNumber binding of
    Just lineNumber -> lineNumber `elem` ignoreLines
    Nothing         -> False
sortExpression :: [Int] -> NExprLoc -> NExprLoc
sortExpression ignoreLines (Fix (Compose (AnnUnit exprSpan exprF))) =
  Fix . Compose . AnnUnit exprSpan $ case exprF of
    NAbs params body ->
      let sortedParams = case params of
            ParamSet atPattern variadic paramList ->
              ParamSet atPattern variadic (sortBy (comparing fst) paramList)
            _ -> params
       in NAbs sortedParams (sortExpression ignoreLines body)
    NList items ->
      let sortedItems = map (sortExpression ignoreLines) items
       in NList $ sortBy (comparing renderExpressionText) sortedItems
    NSet rec bindings ->
      NSet rec $ sortAndCollapseBindings ignoreLines bindings
    NLet bindings body ->
      NLet
        (sortAndCollapseBindings ignoreLines bindings)
        (sortExpression ignoreLines body)
    otherExpr -> fmap (sortExpression ignoreLines) otherExpr
getBindingName :: Binding r -> Text
getBindingName (NamedVar (StaticKey (VarName keyText) :| _) _ _) = keyText
getBindingName (NamedVar (DynamicKey (Plain (DoubleQuoted [Plain keyText])) :| _) _ _) = keyText
getBindingName _ = empty
sortAndCollapseBindings :: [Int] -> [Binding NExprLoc] -> [Binding NExprLoc]
sortAndCollapseBindings ignoreLines bindings =
  concatMap (processSegment ignoreLines) (splitByIgnoredBindings ignoreLines bindings)
sortAndCollapseBindingsUnchecked :: [Int] -> [Binding NExprLoc] -> [Binding NExprLoc]
sortAndCollapseBindingsUnchecked ignoreLines =
  concatMap (collapseNestedBindings ignoreLines)
    . groupBy ((==) `on` getBindingName)
    . sortBy (comparing getBindingName)
type BindingSegment :: Type
data BindingSegment
  = IgnoredBinding (Binding NExprLoc)
  | NormalBindings [Binding NExprLoc]
splitByIgnoredBindings :: [Int] -> [Binding NExprLoc] -> [BindingSegment]
splitByIgnoredBindings _ [] = []
splitByIgnoredBindings ignoreLines bindings@(firstBinding : restBindings)
  | isIgnoredBinding ignoreLines firstBinding =
      IgnoredBinding firstBinding : splitByIgnoredBindings ignoreLines restBindings
  | otherwise =
      let (segment, remaining) = break (isIgnoredBinding ignoreLines) bindings
       in NormalBindings segment : splitByIgnoredBindings ignoreLines remaining
processSegment :: [Int] -> BindingSegment -> [Binding NExprLoc]
processSegment ignoreLines (IgnoredBinding binding) =
  [fmap (sortExpression ignoreLines) binding]
processSegment ignoreLines (NormalBindings bindings) =
  sortAndCollapseBindingsUnchecked ignoreLines bindings
collapseNestedBindings :: [Int] -> [Binding NExprLoc] -> [Binding NExprLoc]
collapseNestedBindings _ [] = []
collapseNestedBindings ignoreLines bindings@(firstBinding : _) =
  case firstBinding of
    NamedVar (bindingKey :| _) _ bindingPos ->
      let nestedBindings = concatMap (nextLevelBindings ignoreLines) bindings
          sortedNested = sortAndCollapseBindings ignoreLines nestedBindings
       in case sortedNested of
            [] -> map (fmap (sortExpression ignoreLines)) bindings
            [NamedVar (subKey :| restKeys) valExpr _] ->
              [NamedVar (bindingKey :| subKey : restKeys) valExpr bindingPos]
            newNested ->
              [ NamedVar
                  (bindingKey :| [])
                  (Fix (Compose (AnnUnit (SrcSpan bindingPos bindingPos) (NSet NonRecursive newNested))))
                  bindingPos
              ]
    _ -> map (fmap (sortExpression ignoreLines)) bindings
nextLevelBindings :: [Int] -> Binding NExprLoc -> [Binding NExprLoc]
nextLevelBindings _ (NamedVar (_ :| bindingKey : restKeys) valExpr bindingPos) =
  [NamedVar (bindingKey :| restKeys) valExpr bindingPos]
nextLevelBindings _ (NamedVar (_ :| []) (Fix (Compose (AnnUnit _ (NSet _ nested)))) _) = nested
nextLevelBindings _ _ = []
makeFormattingTest :: String -> Text -> Text -> Test
makeFormattingTest testName input expectedOutput = TestCase $ do
  withSystemTempFile "test.nix" $ \tmpFile tmpHandle -> do
    hClose tmpHandle
    writeFile tmpFile input
    parseResult <- parseNixFileLoc (Path tmpFile)
    case parseResult of
      Right expr -> do
        writeFormattedFile tmpFile expr
        formatted <- readFile tmpFile
        assertEqual testName expectedOutput formatted
      Left parseError ->
        assertFailure $ "Parse error in test '" ++ testName ++ "': " ++ show parseError
getAllFormattingTests :: Test
getAllFormattingTests =
  TestList
    [ makeFormattingTest
        "list sorting"
        (pack "[ \"c\" \"a\" \"b\" ]")
        (pack "[\n  \"a\"\n  \"b\"\n  \"c\"\n]"),
      makeFormattingTest
        "parameter sorting"
        (pack "{ x = { z, x, y }: x + y + z; }")
        (pack "{\n  x = { x\n    , y\n    , z }:\n    x + y + z;\n}"),
      makeFormattingTest
        "attribute set sorting"
        (pack "{ c = 1; a = 2; b = 3; }")
        (pack "{\n  a = 2;\n  b = 3;\n  c = 1;\n}"),
      makeFormattingTest
        "nested attribute set sorting"
        (pack "{ b = { z = 1; x = 2; }; a = 1; }")
        (pack "{\n  a = 1;\n  b = {\n    x = 2;\n    z = 1;\n  };\n}"),
      makeFormattingTest
        "dotted list collapse"
        (pack "{ a = { b = [ \"c\" ]; }; }")
        (pack "{\n  a.b = [\n    \"c\"\n  ];\n}"),
      makeFormattingTest
        "dotted nested collapse"
        (pack "{ b = { z = 1; }; a = 1; }")
        (pack "{\n  a = 1;\n  b.z = 1;\n}"),
      makeFormattingTest
        "dotted attribute preservation"
        (pack "{ b.z = 1; a = 1; }")
        (pack "{\n  a = 1;\n  b.z = 1;\n}"),
      makeFormattingTest
        "dotted to nested conversion"
        (pack "{ b.z = 1; b.x = 2; a = 1; }")
        (pack "{\n  a = 1;\n  b = {\n    x = 2;\n    z = 1;\n  };\n}"),
      makeFormattingTest
        "multi-dotted to nested conversion"
        (pack "{ b.z.b = 1; b.z.a = 2; }")
        (pack "{\n  b.z = {\n    a = 2;\n    b = 1;\n  };\n}"),
      makeFormattingTest
        "let expression sorting"
        (pack "let c = 1; a = 2; b = 3; in a + b + c")
        (pack "let\n  a = 2;\n  b = 3;\n  c = 1;\nin a + b + c"),
      makeFormattingTest
        "let with nested set sorting"
        (pack "let c = { z = 1; x = 2; }; a = 1; in a + c.x + c.z")
        (pack "let\n  a = 1;\n  c = {\n    x = 2;\n    z = 1;\n  };\nin a + c.x + c.z"),
      makeFormattingTest
        "deep nested collapse"
        (pack "{ c = { z = { x = 2; }; }; }")
        (pack "{\n  c.z.x = 2;\n}"),
      makeFormattingTest
        "string key sorting"
        (pack "{ \"b\".val1 = 1; \"a\".val2 = 2; }")
        (pack "{\n  \"a\".val2 = 2;\n  \"b\".val1 = 1;\n}"),
      makeFormattingTest
        "multiline string preservation"
        (pack "{ a = ''\n  line1\n  line2\n''; }")
        (pack "{\n  a = ''\n    line1\n    line2\n    '';\n}"),
      makeFormattingTest
        "python template installPhase preservation"
        (pack "{ installPhase = ''\nmkdir -p $out/bin\ncp ./main.py $out/bin/${pname}\n''; }")
        (pack "{\n  installPhase = ''\n    mkdir -p $out/bin\n    cp ./main.py $out/bin/${pname}\n    '';\n}"),
      makeFormattingTest
        "ignore binding line"
        (pack "{\n  d = 4;\n  b = 2;\n  c = 3; # nix-alphabetize-ignore\n  a = 1;\n  e = 5;\n}")
        (pack "{\n  b = 2;\n  d = 4;\n  c = 3; # nix-alphabetize-ignore\n  a = 1;\n  e = 5;\n}"),
      makeFormattingTest
        "ignore binding sorts nested"
        (pack "{\n  a = { z = 1; x = 2; }; # nix-alphabetize-ignore\n  b = 1;\n}")
        (pack "{\n  a = { # nix-alphabetize-ignore\n    x = 2;\n    z = 1;\n  };\n  b = 1;\n}")
    ]
