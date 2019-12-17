{-|
Extra types and aliases.
-}
module Coalmine.Types where

import Prelude
import qualified Text.Builder as TextBuilder
import qualified Data.Vector.Unboxed
import qualified Data.Vector


type TextBuilder = TextBuilder.Builder

type UVec = Data.Vector.Unboxed.Vector

type Vec = Data.Vector.Vector
