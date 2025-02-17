-- |
-- Generic helpers for HeadedMegaparsec.
module Coalmine.HeadedMegaparsecExtras where

import Coalmine.InternalPrelude hiding (bit, filter, head, some, sortBy, tail, try)
import Coalmine.Located qualified as Located
import Coalmine.MegaparsecExtras qualified as MegaparsecExtras
import Data.CaseInsensitive (FoldCase)
import HeadedMegaparsec
import Text.Megaparsec (Stream, TraversableStream, VisualStream)
import Text.Megaparsec qualified as Megaparsec
import Text.Megaparsec.Char qualified as MegaparsecChar
import Text.Megaparsec.Char.Lexer qualified as MegaparsecLexer

-- $setup
-- >>> testParser parser = either putStr print . run parser

-- * Executors

-- |
-- Execute as single input chunk refiner.
toRefiner ::
  (VisualStream strm, TraversableStream strm, Megaparsec.ShowErrorComponent err) =>
  HeadedParsec err strm a ->
  strm ->
  Either Text a
toRefiner p =
  first (fromString . Megaparsec.errorBundlePretty)
    . Megaparsec.runParser (toParsec p <* Megaparsec.eof) ""

-- * Primitives

-- |
-- Lifted megaparsec\'s `Megaparsec.eof`.
eof :: (Ord err, Stream strm) => HeadedParsec err strm ()
eof = parse Megaparsec.eof

-- |
-- Lifted megaparsec\'s `Megaparsec.space`.
space :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char) => HeadedParsec err strm ()
space = parse MegaparsecChar.space

-- |
-- Lifted megaparsec\'s `Megaparsec.space1`.
space1 :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char) => HeadedParsec err strm ()
space1 = parse MegaparsecChar.space1

-- |
-- Lifted megaparsec\'s `Megaparsec.char`.
char :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char) => Char -> HeadedParsec err strm Char
char a = parse (MegaparsecChar.char a)

-- |
-- Lifted megaparsec\'s `Megaparsec.char'`.
char' :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char) => Char -> HeadedParsec err strm Char
char' a = parse (MegaparsecChar.char' a)

-- |
-- Lifted megaparsec\'s `Megaparsec.string`.
string :: (Ord err, Stream strm) => Megaparsec.Tokens strm -> HeadedParsec err strm (Megaparsec.Tokens strm)
string = parse . MegaparsecChar.string

-- |
-- Lifted megaparsec\'s `Megaparsec.string'`.
string' :: (Ord err, Stream strm, FoldCase (Megaparsec.Tokens strm)) => Megaparsec.Tokens strm -> HeadedParsec err strm (Megaparsec.Tokens strm)
string' = parse . MegaparsecChar.string'

-- |
-- Lifted megaparsec\'s `Megaparsec.takeWhileP`.
takeWhileP :: (Ord err, Stream strm) => Maybe String -> (Megaparsec.Token strm -> Bool) -> HeadedParsec err strm (Megaparsec.Tokens strm)
takeWhileP label predicate = parse (Megaparsec.takeWhileP label predicate)

-- |
-- Lifted megaparsec\'s `Megaparsec.takeWhile1P`.
takeWhile1P :: (Ord err, Stream strm) => Maybe String -> (Megaparsec.Token strm -> Bool) -> HeadedParsec err strm (Megaparsec.Tokens strm)
takeWhile1P label predicate = parse (Megaparsec.takeWhile1P label predicate)

satisfy :: (Ord err, Stream strm) => (Megaparsec.Token strm -> Bool) -> HeadedParsec err strm (Megaparsec.Token strm)
satisfy = parse . Megaparsec.satisfy

decimal :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char, Integral decimal) => HeadedParsec err strm decimal
decimal = parse MegaparsecLexer.decimal

float :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char, RealFloat float) => HeadedParsec err strm float
float = parse MegaparsecLexer.float

-- * Combinators

sep :: (Ord err, Stream strm) => HeadedParsec err strm separtor -> HeadedParsec err strm a -> HeadedParsec err strm [a]
sep _separator _parser = do
  _head <- _parser
  endHead
  _tail <- many $ _separator *> _parser
  return (_head : _tail)

sep1 :: (Ord err, Stream strm) => HeadedParsec err strm separtor -> HeadedParsec err strm a -> HeadedParsec err strm (NonEmpty a)
sep1 _separator _parser = do
  _head <- _parser
  endHead
  _tail <- many $ _separator *> _parser
  return (_head :| _tail)

sepEnd1 :: (Ord err, Stream strm) => HeadedParsec err strm separator -> HeadedParsec err strm end -> HeadedParsec err strm el -> HeadedParsec err strm (NonEmpty el, end)
sepEnd1 sepP endP elP = do
  headEl <- elP
  let loop !list = do
        _ <- sepP
        asum
          [ do
              end <- endP
              return (headEl :| reverse list, end),
            do
              el <- elP
              loop (el : list)
          ]
   in loop []

notFollowedBy :: (Ord err, Stream strm) => HeadedParsec err strm a -> HeadedParsec err strm ()
notFollowedBy a = parse (Megaparsec.notFollowedBy (toParsec a))

-- * --

liftEither :: (Stream s, Ord e) => Either Text a -> HeadedParsec e s a
liftEither = \case
  Left err -> fail . to $ err
  Right res -> return res

-- |
-- Post-process the result of a parser with a possible failure.
--
-- In case of failure the cursor gets positioned
-- in the beginning of the parsed input.
refine :: (Stream s, Ord e) => (a -> Either Text b) -> HeadedParsec e s a -> HeadedParsec e s b
refine refiner parser =
  do
    initialState <- parse $ Megaparsec.getParserState
    parserResult <- parser
    case refiner parserResult of
      Right res -> return res
      Left err -> do
        parse $ Megaparsec.updateParserState (const initialState)
        fail . to $ err

sepUpdate :: (Stream s, Ord e) => state -> HeadedParsec e s sep -> (state -> HeadedParsec e s state) -> HeadedParsec e s state
sepUpdate state sepP elemP =
  sepUpdate1 state sepP elemP <|> pure state

sepUpdate1 :: (Stream s, Ord e) => state -> HeadedParsec e s sep -> (state -> HeadedParsec e s state) -> HeadedParsec e s state
sepUpdate1 state sepP elemP = do
  state <- elemP state
  let go !state =
        asum
          [ do
              sepP
              state <- elemP state
              go state,
            return state
          ]
   in go state

sepEndUpdate :: (Stream s, Ord e) => state -> HeadedParsec e s sep -> (state -> HeadedParsec e s end) -> (state -> HeadedParsec e s state) -> HeadedParsec e s end
sepEndUpdate state sepP endP elemP =
  asum
    [ endP state,
      do
        state <- elemP state
        let go !state =
              asum
                [ do
                    sepP
                    state <- elemP state
                    go state,
                  endP state
                ]
         in go state
    ]

-- * --

locate :: (Stream s, Ord e) => HeadedParsec e s res -> HeadedParsec e s (Located.Located res)
locate =
  parse . MegaparsecExtras.locate . toParsec
