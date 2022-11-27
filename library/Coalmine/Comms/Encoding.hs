module Coalmine.Comms.Encoding where

import Coalmine.InternalPrelude
import Coalmine.PtrKit.StreamingPoker qualified as StreamingPoker

data Encoding = Encoding
  { size :: Int,
    write :: StreamingPoker.StreamingPoker
  }

instance Semigroup Encoding where
  Encoding leftSize leftWrite <> Encoding rightSize rightWrite =
    Encoding (leftSize + rightSize) (leftWrite <> rightWrite)

instance Monoid Encoding where
  mempty = Encoding 0 mempty

varLengthInteger :: Integer -> Encoding
varLengthInteger =
  error "TODO"

failure :: Text -> Encoding
failure reason =
  Encoding 0 $ StreamingPoker.failure reason