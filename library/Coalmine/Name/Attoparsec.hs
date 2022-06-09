module Coalmine.Name.Attoparsec where

import Coalmine.AttoparsecExtras.Text
import Coalmine.InternalPrelude
import qualified Coalmine.Name.Charsets as Charsets
import Data.Attoparsec.Text hiding (sepBy, sepBy1)
import VectorBuilder.MonadPlus

complete parser = parser <* endOfInput

parts = sepBy1 part (char '-')

part = textOfCharset1 Charsets.part
