module TestSuites.ConduitExtras where

import Coalmine.ConduitExtras qualified as ConduitExtras
import Coalmine.Prelude
import Coalmine.Tasty
import Conduit

tests :: [TestTree]
tests =
  [ testCase "Discretization" $
      let conduit =
            yieldMany input
              .| ConduitExtras.discretize 10 fst (\ts (_, x) -> (ts, x))
              .| sinkList
          input =
            [ (3, 0),
              (13, 3),
              (23, 4),
              (24, 5),
              (54, 6),
              (63, 7)
            ]
          expectation =
            [ (13, 0),
              (23, 3),
              (33, 5),
              (43, 5),
              (53, 5),
              (63, 6),
              (73, 7)
            ]
          reality =
            runConduitPure conduit
       in assertEqual @[(Int, Int)] "" expectation reality
  ]
