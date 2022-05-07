module Coalmine.UnorderedContainersExtras.HashMap where

import Coalmine.InternalPrelude hiding (empty, insert)
import Data.HashMap.Strict

{-# INLINE traverse_ #-}
traverse_ :: Applicative m => (k -> v -> m ()) -> HashMap k v -> m ()
traverse_ m =
  foldrWithKey step init
  where
    init = pure ()
    step k v acc = m k v *> acc

{-# INLINE replicateM #-}
replicateM :: (Monad m, Eq k, Hashable k) => Int -> m (k, v) -> m (HashMap k v)
replicateM amount m =
  let iterate index !state =
        if index < amount
          then do
            (k, v) <- m
            iterate (succ index) (insert k v state)
          else return state
   in iterate 0 empty
