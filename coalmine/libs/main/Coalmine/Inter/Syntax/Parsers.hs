module Coalmine.Inter.Syntax.Parsers where

import Coalmine.BaseExtras.Function
import Coalmine.EvenSimplerPaths.AttoparsecHelpers
import Coalmine.Inter.Syntax.Model
import Coalmine.InternalPrelude hiding (takeWhile)
import Data.Attoparsec.Text
import VectorExtras.Combinators qualified as VectorCombinators

quasiQuote :: Parser QuasiQuote
quasiQuote =
  multiline <|> uniline
  where
    multiline = do
      spaces
      endOfLine
      MultilineQuasiQuote <$> content
      where
        content =
          VectorCombinators.sepEnd sep end line
          where
            sep = endOfLine
            end = endOfLine >> spaces >> endOfInput
    uniline =
      UnilineQuasiQuote <$> line <* endOfInput

spaces :: Parser (BVec Space)
spaces =
  VectorCombinators.many space
  where
    space =
      asum
        [ SpaceSpace <$ char ' ',
          TabSpace <$ char '\t'
        ]

line :: Parser Line
line =
  Line <$> spaces <*> VectorCombinators.many contentSegment

contentSegment :: Parser ContentSegment
contentSegment =
  asum
    [ PlainContentSegment <$> takeWhile1 isPlainContentChar,
      do
        _ <- char '$'
        asum
          [ PlaceholderContentSegment <$> (char '{' *> sepByNonEmpty name (char '.') <* char '}'),
            PlainContentSegment <$> (string "${" <|> pure "$")
          ]
    ]
  where
    isPlainContentChar x =
      x /= '\n' && x /= '\r' && x /= '$'

name :: Parser Name
name =
  Name <$> head <*> tail
  where
    head = satisfy $ \a ->
      isAlpha a && isLower a || a == '_'
    tail = takeWhile $ or . applyAll [isAlphaNum, (== '_'), (== '\'')]
