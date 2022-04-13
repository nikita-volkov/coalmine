-- |
-- Layout for text with indentation using efficient specialised builders.
module Coalmine.Inter where

import qualified Coalmine.Inter.Deindentation as Deindentation
import qualified Coalmine.Inter.Format.Parsers as Parsers
import qualified Coalmine.Inter.TH as InterTH
import Coalmine.InternalPrelude
import qualified Coalmine.TH as TH

i :: QuasiQuoter
i = TH.pureAttoparsedExpQq parser
  where
    parser =
      Parsers.quasiQuote
        <&> InterTH.linesExp . Deindentation.quasiQuote
