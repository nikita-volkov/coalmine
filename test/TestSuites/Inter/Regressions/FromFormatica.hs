module TestSuites.Inter.Regressions.FromFormatica where

import Coalmine.Inter
import Coalmine.MultilineTextBuilder qualified as B
import Coalmine.Prelude
import Data.Text qualified as Text
import Test.QuickCheck qualified as QuickCheck
import Test.QuickCheck.Instances
import Test.QuickCheck.Property qualified as QuickCheck
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck
import Test.Tasty.Runners

tests =
  [ testCase "Nested indentation" $
      let expected =
            "a :: Parser A\n\
            \a =\n\
            \  asum\n\
            \    [ a,\n\
            \      b,\n\
            \      c\n\
            \    ]"
          actual =
            parserDecl "a" "A" $
              alternativeExp
                [ "a",
                  "b",
                  "c"
                ]
       in assertEqual "" expected actual
  ]

-- * Prerequisites

multilineList :: [B.Builder] -> B.Builder
multilineList =
  \case
    [] -> "[]"
    a : b -> "[ " <> a <> B.indent 2 (foldMap (mappend ",\n") b) <> "\n]"

staticMonoid :: [B.Builder] -> B.Builder
staticMonoid = \case
  [] -> "mempty"
  [a] -> a
  a -> "mconcat " <> B.indent 2 ("\n" <> multilineList a)

alternativeExp :: [B.Builder] -> B.Builder
alternativeExp = \case
  [] -> "empty"
  [a] -> a
  options ->
    [i|
      asum
        $optionsList
    |]
    where
      optionsList =
        multilineList options

parserDecl :: B.Builder -> B.Builder -> B.Builder -> B.Builder
parserDecl parserName modelTypeName exp =
  [i|
    $parserName :: Parser $modelTypeName
    $parserName =
      $exp
  |]
