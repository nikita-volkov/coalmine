module Coalmine.Inter.Syntax.Model where

import Coalmine.InternalPrelude
import Domain qualified

Domain.declare
  Nothing
  ( mconcat
      [ Domain.enumDeriver,
        Domain.boundedDeriver,
        Domain.showDeriver,
        Domain.eqDeriver,
        Domain.ordDeriver,
        Domain.genericDeriver,
        Domain.accessorIsLabelDeriver,
        Domain.constructorIsLabelDeriver
      ]
  )
  =<< Domain.loadSchema "domain/inter-syntax.domain.yaml"
