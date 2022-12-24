module Coalmine.NumericVersion
  ( NumericVersion,
    lit,
    parts,
    bump,
  )
where

import Coalmine.InternalPrelude
import Coalmine.Parsing
import Coalmine.Printing
import Coalmine.TH.QuasiQuoter qualified as QuasiQuoter
import Data.Attoparsec.Text qualified as Attoparsec

data NumericVersion = NumericVersion
  { head :: !Word,
    tail :: ![Word]
  }
  deriving (Eq, Show, Generic, Lift)

instance Ord NumericVersion where
  compare l r =
    compare (parts l) (parts r)

instance CompactPrinting NumericVersion where
  toCompactBuilder (NumericVersion h t) =
    toCompactBuilder h
      <> foldMap (mappend "." . toCompactBuilder) t

instance BroadPrinting NumericVersion where
  toBroadBuilder = to . toCompactBuilder

instance ToJSON NumericVersion where
  toJSON = toJSON . printCompactAs @Text

instance ToJSONKey NumericVersion where
  toJSONKey = printCompactAs @Text >$< toJSONKey

instance LenientParser NumericVersion where
  lenientParser = do
    head <- Attoparsec.decimal
    tail <- many tailSegmentParser
    return (NumericVersion head tail)
    where
      tailSegmentParser = do
        Attoparsec.char '.'
        Attoparsec.decimal

lit :: QuasiQuoter
lit =
  QuasiQuoter.lenientLiteral $ Proxy @NumericVersion

parts :: NumericVersion -> [Word]
parts (NumericVersion head tail) =
  head : tail

-- | Bump the version at the specified position,
-- introducing the position if it does not exist.
bump :: Int -> NumericVersion -> NumericVersion
bump position (NumericVersion head tail) =
  case position of
    0 -> NumericVersion (succ head) []
    _ -> NumericVersion head newTail
      where
        newTail = eliminateTail (pred position) tail
          where
            eliminateTail !position = \case
              h : t ->
                case position of
                  0 -> [succ h]
                  _ -> h : eliminateTail (pred position) t
              [] ->
                replicate position 0 <> [1]