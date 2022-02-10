module Coalmine.BasePreludes.Operators
  ( -- * From "Control.Applicative":
    (Control.Applicative.*>),
    (Control.Applicative.<*),
    (Control.Applicative.<*>),
    (Control.Applicative.<|>),

    -- * From "Control.Monad":
    (Control.Monad.<=<),
    (Control.Monad.=<<),
    (Control.Monad.>=>),
    (Control.Monad.>>),
    (Control.Monad.>>=),

    -- * From "Data.Bool":
    (Data.Bool.&&),
    (Data.Bool.||),
    (Data.Eq./=),
    (Data.Eq.==),

    -- * From "Data.Function":
    (Data.Function.$),
    (Data.Function.&),
    (Data.Function..),

    -- * From "Data.Functor":
    (Data.Functor.$>),
    (Data.Functor.<$),
    (Data.Functor.<$>),
    (Data.Functor.<&>),

    -- * From "Data.Ord":
    (Data.Ord.<),
    (Data.Ord.<=),
    (Data.Ord.>),
    (Data.Ord.>=),

    -- * From "Data.Ratio":
    (Data.Ratio.%),

    -- * From "Data.Semigroup":
    (Data.Semigroup.<>),

    -- * From "Prelude":
    (Prelude.$!),
    (Prelude.*),
    (Prelude.+),
    (Prelude.-),
    (Prelude./),
    (Prelude.^),
    (Prelude.^^),
  )
where

import qualified Control.Applicative
import qualified Control.Monad
import qualified Data.Bool
import qualified Data.Eq
import qualified Data.Function
import qualified Data.Functor
import qualified Data.Ord
import qualified Data.Ratio
import qualified Data.Semigroup
import qualified Prelude
