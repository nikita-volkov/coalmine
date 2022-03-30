module Coalmine.InternalPrelude
  ( module Prelude,
    module Exports,
    showAsText,
    traceMap,
    E8,
  )
where

import Acc as Exports (Acc)
import Acc.NeAcc as Exports (NeAcc)
import Attoparsec.Data as Exports (LenientParser (..))
import Coalmine.BaseExtras.Alternative as Exports
import Coalmine.BaseExtras.Function as Exports
import Coalmine.TextConversionsExtras.Instances as Exports
import Control.FromSum as Exports
import Control.Monad.Morph as Exports
import Data.Aeson as Exports (FromJSON (..), ToJSON (..), ToJSONKey (..))
import Data.Decimal as Exports (Decimal)
import Data.Default as Exports
import Data.DoubleWord as Exports (Word128 (..), Word160 (..), Word192 (..), Word224 (..), Word256 (..), Word96 (..))
import Data.Functor.Invariant as Exports
import Data.Group as Exports
import Data.Groupoid as Exports
import Data.Machine.Mealy as Exports
import Data.Machine.Moore as Exports
import Data.String.ToString as Exports
import Data.Text.Conversions as Exports
import Data.Time.Compat as Exports ()
import Data.Tuple.All as Exports hiding (only)
import Data.Vector.Generic as Exports (Vector)
import Data.Vector.Instances as Exports
import Data.Vector.Unboxed as Exports (Unbox)
import Data.Vector.Unboxed.Deriving as Exports (derivingUnbox)
import DeferredFolds.Unfoldr as Exports (Unfoldr (..))
import Deque.Strict as Exports (Deque)
import GHC.Exts as Exports (IsList (..))
import Language.Haskell.TH.Quote as Exports (QuasiQuoter (..))
import Language.Haskell.TH.Syntax as Exports (Lift, Q)
import Network.IP.Addr as Exports (IP (..), IP4 (..), IP6 (..), InetAddr (..), InetPort (..), NetAddr (..))
import System.IO as Exports
import TextBuilderDev as Exports (TextBuilder, ToTextBuilder (..), buildText)
import Prelude hiding (Vector, chosen, toList, uncons, (%))

showAsText :: Show a => a -> Text
showAsText = show >>> fromString

traceMap :: (a -> String) -> a -> a
traceMap f a = trace (f a) a

data E8

instance HasResolution E8 where
  resolution _ = 100000000
