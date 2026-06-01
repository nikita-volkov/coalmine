module Coalmine.Building where

import Coalmine.InternalPrelude

class (Monoid builder) => Building builder where
  type BuilderTarget builder
  toBuilder :: BuilderTarget builder -> builder
  fromBuilder :: builder -> BuilderTarget builder

instance Building TextBuilder where
  type BuilderTarget TextBuilder = Text
  toBuilder = to
  fromBuilder = to
