module TestSuites.EvenSimplerPaths where

import Coalmine.EvenSimplerPaths
import Coalmine.Prelude
import Coalmine.Tasty

tests =
  [ testGroup
      "Essentials"
      [ eqTestCase
          "Component decomposition works and keeps order"
          ["src", "main", "java"]
          (components "src/main/java")
      ],
    testGroup
      "Dot"
      [ eqTestCase
          "equals empty"
          (Right mempty)
          (parseTextLeniently @Path "."),
        eqTestCase
          "acts as a normal component"
          (Right "src/main")
          (parseTextLeniently @Path "src/./main")
      ],
    testGroup
      "Trailing slash"
      [ eqTestCase
          "Same as without it"
          (Right "src/main/java")
          (parseTextLeniently @Path "src/main/java/"),
        eqTestCase
          "Doesn't produce a trailing component"
          ["src", "main", "java"]
          (components "src/main/java/")
      ],
    testGroup
      "Multislash"
      [ eqTestCase
          "Double"
          (Right "src/main")
          (parseTextLeniently @Path "src//main"),
        eqTestCase
          "Triple"
          (Right "src/main")
          (parseTextLeniently @Path "src///main")
      ]
  ]
