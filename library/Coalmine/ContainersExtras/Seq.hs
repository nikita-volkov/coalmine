module Coalmine.ContainersExtras.Seq where

import Coalmine.InternalPrelude hiding (empty, insert)
import Data.Sequence

mapHead :: (a -> a) -> Seq a -> Seq a
mapHead f seq = case viewl seq of
  EmptyL -> mempty
  head :< tail -> f head <| tail

mapTail :: (a -> a) -> Seq a -> Seq a
mapTail f seq = case viewl seq of
  EmptyL -> mempty
  head :< tail -> head <| fmap f tail

mapTailTip :: (a -> a) -> Seq a -> Seq a
mapTailTip f seq = case viewr seq of
  EmptyR -> mempty
  init :> tailTip -> init |> f tailTip

mapInit :: (a -> a) -> Seq a -> Seq a
mapInit f seq = case viewr seq of
  EmptyR -> mempty
  init :> tailTip -> fmap f init |> tailTip
