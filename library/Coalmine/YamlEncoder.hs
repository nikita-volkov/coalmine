module Coalmine.YamlEncoder where

import Coalmine.Prelude

-- |
-- Specification of how to serialize a data structure as YAML.
--
-- Can be used to generate 'Schema' for generating format spec
-- to external processes or for generating code.
data YamlEncoder a

renderValueAsText :: YamlEncoder a -> a -> Text
renderValueAsText =
  error "TODO"

renderSchema :: YamlEncoder a -> Schema
renderSchema =
  error "TODO"

-- |
-- Description of the structure of YAML to be produced.
--
-- Can be used to produce specifications and code generators.
data Schema
