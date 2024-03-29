module Coalmine.UnorderedContainersExtras.HashSet where

import Coalmine.InternalPrelude as Prelude hiding (empty, insert)
import Data.HashSet

fromFoldable :: (Foldable f, Hashable a) => f a -> HashSet a
fromFoldable =
  Prelude.foldl' (flip insert) empty
