module Coalmine.HaskellCodegens.Model where

import Coalmine.HaskellCodegens.Base
import Coalmine.InternalPrelude

compileModelModules :: Model -> [Module]
compileModelModules =
  error "TODO"

data Model = Model
  { -- An open protocol for custom extensions with a set of standard ones provided out of the box.
    --
    -- FIXME: It's premature.
    -- Switch to closed protocol instead. There should be a finite set of useful features.
    -- Until people start requesting it, avoid providing such a feature.
    features :: [Feature],
    structures :: [Structure]
  }

data Feature = Feature
  { isClassInstance :: Bool,
    orderingKey :: Text,
    structureModuleCode :: Structure -> Maybe Code,
    customClassDeclaration :: Maybe Code
  }

data Structure = Structure
  { name :: Text,
    definition :: StructureDefinition
  }

data StructureDefinition
  = ProductStructureDefinition ProductDefinition
  | RefinedStructureDefinition RefinedType

data RefinedType
  = IntegerRefinedType IntegerRestrictions
  | StringRefinedType StringRestrictions
  | VectorRefinedType VectorRestrictions

data IntegerRestrictions = IntegerRestrictions
  { min :: Maybe Integer,
    max :: Maybe Integer
  }

data StringRestrictions = StringRestrictions
  { regex :: Maybe Text,
    minLength :: Maybe Int,
    maxLength :: Maybe Int
  }

data VectorRestrictions = VectorRestrictions
  { element :: Either RefinedType Type,
    minLength :: Maybe Int,
    maxLength :: Maybe Int
  }

data ProductDefinition = ProductDefinition
  { fields :: [ProductField]
  }

data ProductField = ProductField
  { name :: Text,
    type_ :: Type,
    anonymize :: Bool
  }

data Type
  = ModelType Text
  | MaybeType Type
  | VectorType Type
  | IntType
  | FloatType
  | ScientificType
  | TextType
  | UuidType
  | EmailType
  | UrlType
  | IpType

data Code = Code
  { importRequests :: [ImportRequest],
    printer :: (Import -> Text) -> TextBuilder
  }

data ImportRequest = ImportRequest
  { import_ :: Import,
    alias :: Text
  }

data Import = Import
  { -- | Possible external dependency.
    -- Affects the Cabal-file.
    --
    -- Nothing means that the module is from this package.
    dependency :: Maybe Dependency,
    name :: Text
  }

-- * Feature Gens

-- ** Literal Feature Gen