module Coalmine.Inter.Normalization
  ( -- *
    Line (..),
    M.ContentSegment (..),
    M.Name (..),

    -- *
    quasiQuote,
  )
where

import qualified Coalmine.Inter.Format.Model as M
import Coalmine.Prelude
import qualified Data.Vector as BVec

spacesIndentation :: BVec M.Space -> Int
spacesIndentation = getSum . foldMap (Sum . spaceIndentation)

spaceIndentation :: M.Space -> Int
spaceIndentation = \case
  M.SpaceSpace -> 1
  M.TabSpace -> 2

lineIndentedSegments :: M.Line -> (Int, BVec M.ContentSegment)
lineIndentedSegments =
  (,) <$> spacesIndentation . #indentation <*> #content

quasiQuoteIndentedSegments :: M.QuasiQuote -> BVec (Int, BVec M.ContentSegment)
quasiQuoteIndentedSegments =
  fmap lineIndentedSegments . #content

-- *

line :: M.Line -> Line
line fmt =
  if BVec.null (#content fmt)
    then BlankLine
    else ContentLine (spacesIndentation (#indentation fmt)) (#content fmt)

-- *

minimalIndent :: BVec Line -> Int
minimalIndent =
  BVec.minimum
    . BVec.mapMaybe
      ( \case
          BlankLine -> Nothing
          ContentLine indentation _ -> Just indentation
      )

reduceIndent :: Int -> BVec Line -> BVec Line
reduceIndent minimalIndent =
  BVec.map $ \case
    BlankLine -> BlankLine
    ContentLine indent content -> ContentLine (indent - minimalIndent) content

-- *

content :: BVec M.Line -> BVec Line
content fmt =
  case BVec.map line fmt of
    lines -> case minimalIndent lines of
      minimalIndent -> reduceIndent minimalIndent lines

quasiQuote :: M.QuasiQuote -> BVec Line
quasiQuote = content . #content

-- *

data Line
  = BlankLine
  | ContentLine !Int !(BVec M.ContentSegment)